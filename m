Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 2D61D90023D
	for <linux-mm@kvack.org>; Fri, 24 Jun 2011 12:40:54 -0400 (EDT)
From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 24 Jun 2011 09:40:51 -0700
Subject: RE: [PATCH v2 0/3] support for broken memory modules (BadRAM)
Message-ID: <987664A83D2D224EAE907B061CE93D5301E942ED99@orsmsx505.amr.corp.intel.com>
References: <1308741534-6846-1-git-send-email-sassmann@kpanic.de>
 <20110623133950.GB28333@srcf.ucam.org> <4E0348E0.7050808@kpanic.de>
 <20110623141222.GA30003@srcf.ucam.org> <4E035DD1.1030603@kpanic.de>
 <20110623170014.GN3263@one.firstfloor.org>
 <987664A83D2D224EAE907B061CE93D5301E938F2FD@orsmsx505.amr.corp.intel.com>
 <BANLkTikTTCU3eKkCtrbLbtpLJtksehyEMg@mail.gmail.com>
 <20110624080535.GA19966@phantom.vanrein.org> <4E04B848.6000908@zytor.com>
In-Reply-To: <4E04B848.6000908@zytor.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>, Rick van Rein <rick@vanrein.org>
Cc: Craig Bergstrom <craigb@google.com>, Andi Kleen <andi@firstfloor.org>, Stefan Assmann <sassmann@kpanic.de>, Matthew Garrett <mjg59@srcf.ucam.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mingo@elte.hu" <mingo@elte.hu>, "rdunlap@xenotime.net" <rdunlap@xenotime.net>

> > I am very curious about your findings.  Independently of those, I am in
> > favour of a patch that enables longer e820 tables if it has no further
> > impact on speed or space.
> >=20
>
> That is already in the mainline kernel, although only if fed from the
> boot loader (it was developed in the context of mega-NUMA machines); the
> stub fetching from INT 15h doesn't use this at the moment.

Does it scale?  Current X86 systems go up to about 2TB - presumably
in the form of 256 8GB DIMMs (or maybe 512 4GB ones).  If a faulty
row or column on a DIMM can give rise to 4K bad pages, then these
large systems could conceivably have 1-2 million bad pages (while
still being quite usable - a loss of 4-8G from a 2TB system is down
in the noise).  Can we handle a 2 million entry e820 table? Do we
want to?

Perhaps we may end up with a composite solution. Use e820 to map out
the bad pages below some limit (like 4GB). Preferably in the boot loader
so it can find a range of good memory to load the kernel. Then use
badRAM patterns for addresses over 4GB for Linux to avoid bad pages
by flagging their page structures.

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
