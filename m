Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 165666B003D
	for <linux-mm@kvack.org>; Fri, 11 Dec 2009 12:49:13 -0500 (EST)
Date: Fri, 11 Dec 2009 17:49:03 +0000 (GMT)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: An mm bug in today's 2.6.32 git tree
In-Reply-To: <2375c9f90912101922g5b31e5c9gceeca299b9c2b656@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0912111710440.2009@sister.anvils>
References: <2375c9f90912090238u7487019eq2458210aac4b602@mail.gmail.com>
 <Pine.LNX.4.64.0912091442360.30748@sister.anvils>
 <2375c9f90912092259pe86356cvb716232ba7a4d604@mail.gmail.com>
 <Pine.LNX.4.64.0912100951130.31654@sister.anvils>
 <2375c9f90912101922g5b31e5c9gceeca299b9c2b656@mail.gmail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323584-1845426601-1260553743=:2009"
Sender: owner-linux-mm@kvack.org
To: =?UTF-8?Q?Am=C3=A9rico_Wang?= <xiyou.wangcong@gmail.com>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323584-1845426601-1260553743=:2009
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Fri, 11 Dec 2009, Am=C3=A9rico Wang wrote:
> On Thu, Dec 10, 2009 at 5:56 PM, Hugh Dickins
> <hugh.dickins@tiscali.co.uk> wrote:
> >
> > Please post what this other occasion showed, if you still have the log.
>=20
> Sure, below is the whole thing.

Thanks.  That does give a lot more data, but all it amounts to is
that a page table page has been corrupted between offset 0x20 and 0xbf
(perhaps also outside those limits but we cannot be sure) with:

fb00005e00010000 0008f3271e161f00
004000008b000045 9541420a8f4e11ff
e914e914fb0000e0 008400000ca47700
0000000003000000 43466e6169627609
046873735f043231 636f6c057063745f
0001802100006c61 0000001200780000
6169627609160000 c020c0323143466e
00000001801c0037 00000080fe100078
feff161f02000000 80010037c0f3271e
0a04007800000001 00ef3352fe954142

And whilst that twice contains the string "=09vbianFC12",
that doesn't inspire me to any further insight!

Or, perhaps it is bad RAM after all, and the pmd entry had been
corrupted by one bit, so pointing to the wrong page for the page
table: I still think probably not, but worth giving memtest86+
a good run even so.

There's no evidence here that it is or is not an mm bug:
we'll just have to wait and see what more comes up.

Hugh
--8323584-1845426601-1260553743=:2009--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
