Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id A200D6B0031
	for <linux-mm@kvack.org>; Sat, 22 Oct 2011 02:21:53 -0400 (EDT)
Received: by iagf6 with SMTP id f6so8132747iag.14
        for <linux-mm@kvack.org>; Fri, 21 Oct 2011 23:21:50 -0700 (PDT)
From: Nai Xia <nai.xia@gmail.com>
Reply-To: nai.xia@gmail.com
Subject: Re: kernel 3.0: BUG: soft lockup: find_get_pages+0x51/0x110
Date: Sat, 22 Oct 2011 14:21:23 +0800
References: <201110122012.33767.pluto@agmk.net> <CAPQyPG4SE8DyzuqwG74sE2zuZbDgfDoGDir1xHC3zdED+k=qLA@mail.gmail.com> <201110212336.47267.pluto@agmk.net>
In-Reply-To: <201110212336.47267.pluto@agmk.net>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Message-Id: <201110221421.23181.nai.xia@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?q?Pawe=C5=82_Sikora?= <pluto@agmk.net>
Cc: Hugh Dickins <hughd@google.com>, arekm@pld-linux.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, jpiszcz@lucidpixels.com, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>

On Saturday 22 October 2011 05:36:46 Pawe=C5=82 Sikora wrote:
> On Friday 21 of October 2011 11:07:56 Nai Xia wrote:
> > On Fri, Oct 21, 2011 at 4:07 PM, Pawel Sikora <pluto@agmk.net> wrote:
> > > On Friday 21 of October 2011 14:22:37 Nai Xia wrote:
> > >
> > >> And as a side note. Since I notice that Pawel's workload may include=
 OOM,
> > >
> > > my last tests on patched (3.0.4 + migrate.c fix + vserver) kernel pro=
duce full cpu load
> > > on dual 8-cores opterons like on this htop screenshot -> http://pluto=
=2Eagmk.net/kernel/screen1.png
> > > afaics all userspace applications usualy don't use more than half of =
physical memory
> > > and so called "cache" on htop bar doesn't reach the 100%.
> >=20
> > OK=EF=BC=8Cdid you logged any OOM killing if there was some memory usag=
e burst?
> > But, well my above OOM reasoning is a direct short cut to imagined
> > root cause of "adjacent VMAs which
> > should have been merged but in fact not merged" case.
> > Maybe there are other cases that can lead to this or maybe it's
> > totally another bug....
>=20
> i don't see any OOM killing with my conservative settings
> (vm.overcommit_memory=3D2, vm.overcommit_ratio=3D100).

OK, that does not matter now. Andrea showed us a simpler way to goto
this bug.=20

>=20
> > But still I think if my reasoning is good, similar bad things will
> > happen again some time in the future,
> > even if it was not your case here...
> >=20
> > >
> > > the patched kernel with disabled CONFIG_TRANSPARENT_HUGEPAGE (new thi=
ng in 2.6.38)
> > > died at night, so now i'm going to disable also CONFIG_COMPACTION/MIG=
RATION in next
> > > steps and stress this machine again...
> >=20
> > OK, it's smart to narrow down the range first....
>=20
> disabling hugepage/compacting didn't help but disabling hugepage/compacti=
ng/migration keeps
> opterons stable for ~9h so far. userspace uses ~40GB (from 64) ram, cache=
s reach 100% on htop bar,
> average load ~16. i wonder if it survive weekend...
>=20

Maybe you should give another shot of Andrea's latest anon_vma_order_tail()=
 patch. :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
