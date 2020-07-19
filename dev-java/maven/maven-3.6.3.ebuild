# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit java-pkg-2

MY_PN=apache-${PN%%}
MY_PV=${PV/_alpha/-alpha-}
MY_P="${MY_PN}-${MY_PV}"
MY_MV="${PV%%.*}"

DESCRIPTION="Project Management and Comprehension Tool for Java"
HOMEPAGE="https://maven.apache.org/"

SRC_URI="
	!binary? (
		mirror://apache/maven/maven-${MY_MV}/${PV}/source/${MY_P}-src.tar.gz
	)
	binary? (
		mirror://apache/maven/maven-${MY_MV}/${PV}/binaries/${MY_P}-bin.tar.gz	
	)"


LICENSE="Apache-2.0"
SLOT="3.6"
KEYWORDS="~amd64 ~arm64 ~x86"
IUSE="binary"

DEPEND="
	>=virtual/jdk-1.8
	app-eselect/eselect-java
	!binary? (
		dev-java/maven:3.6
	)"

RDEPEND="
	>=virtual/jre-1.8
	!dev-java/maven-bin:3.6"

S="${WORKDIR}/${MY_P}"

MAVEN="${PN}-${SLOT}"
MAVEN_SHARE="/usr/share/${MAVEN}"

src_compile() {

	local maven_basedir="${T}/m2"
	mkdir -p "${maven_basedir}" || die
	
	if ! use binary; then
		einfo "=== maven compile, local repo location ${maven_basedir}  ..."
		mvn -X -Dmaven.repo.local=${maven_basedir}  -DdistributionTargetDir="${WORKDIR}/${PV}-target" clean package || die "Maven build failed"
	fi
}
src_install() {
	dodir "${MAVEN_SHARE}"

	if ! use binary; then
		local target_path=${WORKDIR}/${PV}-target/
		cp -Rp ${target_path}/bin ${target_path}/boot ${target_path}/conf ${target_path}/lib "${ED}/${MAVEN_SHARE}" || die "failed to copy"
		dodoc ${target_path}/NOTICE ${target_path}/README.txt
	else
		cp -Rp bin boot conf lib "${ED}/${MAVEN_SHARE}" || die "failed to copy"
		dodoc NOTICE README.txt
	fi
	
	java-pkg_regjar "${ED}/${MAVEN_SHARE}"/boot/*.jar
	java-pkg_regjar "${ED}/${MAVEN_SHARE}"/lib/*.jar

	dodir /usr/bin
	dosym "${MAVEN_SHARE}/bin/mvn" /usr/bin/mvn-${SLOT}

	# See bug #342901.
	echo "CONFIG_PROTECT=\"${MAVEN_SHARE}/conf\"" > "${T}/25${MAVEN}" || die
	doenvd "${T}/25${MAVEN}"
}

pkg_postinst() {
	eselect maven update mvn-${SLOT}
}

pkg_postrm() {
	eselect maven update
}
