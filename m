Message-ID: <47D02940.1030707@tuxrocks.com>
Date: Thu, 06 Mar 2008 11:26:24 -0600
From: Frank Sorenson <frank@tuxrocks.com>
MIME-Version: 1.0
Subject: 2.6.25-rc4 OOMs itself dead on bootup
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

2.6.25-rc4 invokes the oom-killer repeatedly when attempting to boot,
eventually panicing with "Out of memory and no killable processes."
This happens since at least 2.6.25-rc3, but 2.6.24 boots just fine,

The system is a Dell Inspiron E1705 running Fedora 8 (x86_64).

My .config is at http://tuxrocks.com/tmp/config-2.6.25-rc4, and a syslog
of the system up until the point where it oom-killed syslog (just before
the panic) is at http://tuxrocks.com/tmp/oom-2.6.25-rc4.txt


Frank
- --
Frank Sorenson - KD7TZK
Linux Systems Engineer, DSS Engineering, UBS AG
frank@tuxrocks.com
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)
Comment: Using GnuPG with Fedora - http://enigmail.mozdev.org

iD8DBQFH0Ck9aI0dwg4A47wRAiE2AJ9fw0tRLtdnDrG7TdaR0721wj69owCgitR/
4XphvHdePCivYnu+gXFAgG8=
=shGl
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
