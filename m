Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id A11456B004D
	for <linux-mm@kvack.org>; Mon, 21 Sep 2009 19:24:59 -0400 (EDT)
From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 21 Sep 2009 16:25:05 -0700
Subject: RE: [PATCH] remove duplicate asm/mman.h files
Message-ID: <57C9024A16AD2D4C97DC78E552063EA3E29CC3F1@orsmsx505.amr.corp.intel.com>
References: <cover.1251197514.git.ebmunson@us.ibm.com>
 <200909181848.42192.arnd@arndb.de>
 <alpine.DEB.1.00.0909181236190.27556@chino.kir.corp.google.com>
 <200909211031.25369.arnd@arndb.de>
 <alpine.DEB.1.00.0909210208180.16086@chino.kir.corp.google.com>
 <Pine.LNX.4.64.0909211258570.7831@sister.anvils>
 <alpine.DEB.1.00.0909211553000.30561@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.1.00.0909211553000.30561@chino.kir.corp.google.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Yu, Fenghua" <fenghua.yu@intel.com>, "ebmunson@us.ibm.com" <ebmunson@us.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-man@vger.kernel.org" <linux-man@vger.kernel.org>, "mtk.manpages@gmail.com" <mtk.manpages@gmail.com>, Randy Dunlap <randy.dunlap@oracle.com>, "rth@twiddle.net" <rth@twiddle.net>, "ink@jurassic.park.msu.ru" <ink@jurassic.park.msu.ru>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>
List-ID: <linux-mm.kvack.org>

>> Is it perhaps the case that some UNIX on ia64 does implement MAP_GROWSUP=
,
>> and these numbers in the Linux ia64 mman.h have been chosen to match tha=
t
>> reference implementation?  Tony will know.  But I wonder if you'd do
>> better at least to leave a MAP_GROWSUP comment on that line, so that
>> somebody doesn't go and reuse the empty slot later on.
>>=20
>
> Reserving the bit from future use by adding a comment may be helpful, but=
=20
> then let's do it for MAP_GROWSDOWN too.

Tony can only speculate because this bit has been in asm/mman.h
since before I started working on Linux (it is in the 2.4.0
version ... which is roughly when I started ... and long before
I was responsible for it).

Perhaps it was assumed that it would be useful?  Linux/ia64 does
use upwardly growing memory areas (the h/w register stack engine
saves "stack" registers to an area that grows upwards).

But since we have survived this long without it actually being
implemented, it may be true that we don't really need it after
all.

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
