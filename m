Date: Thu, 4 Sep 2003 13:14:29 +0200
From: Sebastian Benoit <benoit-lists@fb12.de>
Subject: mm5 acpi compile error in pci_link.c:290
Message-ID: <20030904111451.GA80074@mail.webmonster.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="UlVJffcvxoiEqYs2"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: mochel@osdl.org
List-ID: <linux-mm.kvack.org>

--UlVJffcvxoiEqYs2
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable


  CC      drivers/acpi/pci_link.o
drivers/acpi/pci_link.c: In function `acpi_pci_link_try_get_current':
drivers/acpi/pci_link.c:290: error: `_dbg' undeclared (first use in this
function)
drivers/acpi/pci_link.c:290: error: (Each undeclared identifier is reported
only once
drivers/acpi/pci_link.c:290: error: for each function it appears in.)
make[2]: *** [drivers/acpi/pci_link.o] Error 1
make[1]: *** [drivers/acpi] Error 2
make: *** [drivers] Error 2


from .config:

#
# ACPI (Advanced Configuration and Power Interface) Support
#
CONFIG_ACPI_HT=3Dy
CONFIG_ACPI=3Dy
CONFIG_ACPI_BOOT=3Dy
CONFIG_ACPI_SLEEP=3Dy
CONFIG_ACPI_SLEEP_PROC_FS=3Dy
CONFIG_ACPI_AC=3Dm
# CONFIG_ACPI_BATTERY is not set
CONFIG_ACPI_BUTTON=3Dy
CONFIG_ACPI_FAN=3Dy
CONFIG_ACPI_PROCESSOR=3Dy
CONFIG_ACPI_THERMAL=3Dy
# CONFIG_ACPI_ASUS is not set
# CONFIG_ACPI_TOSHIBA is not set
CONFIG_ACPI_DEBUG=3Dy
CONFIG_ACPI_BUS=3Dy
CONFIG_ACPI_INTERPRETER=3Dy
CONFIG_ACPI_EC=3Dy
CONFIG_ACPI_POWER=3Dy
CONFIG_ACPI_PCI=3Dy
CONFIG_ACPI_SYSTEM=3Dy


/B.
--=20
Sebastian Benoit <benoit-lists@fb12.de>
My mail is GnuPG signed -- Unsigned ones are bogus -- http://www.gnupg.org/
GnuPG 0x5BA22F00 2001-07-31 2999 9839 6C9E E4BF B540  C44B 4EC4 E1BE 5BA2 2=
F00

Die Deutschen sind psychologisch gesehen eher =F6de, aber ethnologisch
interessant. Wenn sie sich freuen wollen, m=FCssen sie erst bei anderen
nachkucken, wie das geht. -- Wiglaf Droste

--UlVJffcvxoiEqYs2
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.2 (FreeBSD)

iD8DBQE/Vx6qTsThvluiLwARAvStAKCr0dRn97hGSsEQpGiLvQu6tyRuKwCgkh6S
zcY3VgyZjgbMnOLqohk7PmU=
=FQwm
-----END PGP SIGNATURE-----

--UlVJffcvxoiEqYs2--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
