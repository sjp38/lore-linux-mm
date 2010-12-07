Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 80D596B0087
	for <linux-mm@kvack.org>; Tue,  7 Dec 2010 15:45:37 -0500 (EST)
MIME-Version: 1.0
Message-ID: <dd88185d-bc2c-4d65-8730-8b1fc712306a@default>
Date: Tue, 7 Dec 2010 12:43:28 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH V0 1/4] kztmem: simplified radix tree data structure
 support
References: <20101207180653.GA28115@ca-server1.us.oracle.com>
In-Reply-To: <20101207180653.GA28115@ca-server1.us.oracle.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Dan Magenheimer <dan.magenheimer@oracle.com>, Chris Mason <chris.mason@oracle.com>, akpm@linux-foundation.org, matthew@wil.cx, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ngupta@vflare.org, jeremy@goop.org, Kurt Hackel <kurt.hackel@oracle.com>, npiggin@kernel.dk, riel@redhat.com, Konrad Wilk <konrad.wilk@oracle.com>, mel@csn.ul.ie, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

> Subject: [PATCH V0 1/4] kztmem: simplified radix tree data structure supp=
ort
>=20
> [PATCH V0 1/4] kztmem: simplified radix tree data structure support

A monolithic patch containing all of kztmem, cleancache, and frontswap
that applies cleanly to 2.6.36 can be found at:

http://oss.oracle.com/projects/tmem/dist/files/kztmem/kztmem-linux-2.6.36-1=
01207.patch=20

(Or http://oss.oracle.com/projects/tmem and Downloads and kztmem patches)
      =20
I'm a git novice but can prepare a git tree also if desired.

To try kztmem:

1) apply the monolithic patch to 2.6.36
2) rebuild your config ensuring that CONFIG_KZTMEM, CONFIG_CLEANCACHE,
   CONFIG_FRONTSWAP, and CONFIG_ZRAM (for xvMalloc) become enabled
3) rebuild and reboot with "kztmem" as a kernel boot parameter
4) see /sys/kernel/mm/kztmem/* for statistics... note that with
   lots of RAM and no swapping, little or no activity will be seen

As I said, there are known weird bugs that may or may not show
up in your configuration and build environment, so be prepared
in advance that the kernel may crash... removing kztmem as
a boot parameter should disable kztmem and result in a normal boot.

Thanks in advance for trying and testing (and, if you are so
inclined, debugging) kztmem!  I'll be happy to answer any
questions on- or off-list!

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
