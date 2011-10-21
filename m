Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id A283B6B0033
	for <linux-mm@kvack.org>; Fri, 21 Oct 2011 05:07:58 -0400 (EDT)
Received: by vws16 with SMTP id 16so3861705vws.14
        for <linux-mm@kvack.org>; Fri, 21 Oct 2011 02:07:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <2109011.boM0eZ0ZTE@pawels>
References: <201110122012.33767.pluto@agmk.net>
	<CANsGZ6a6_q8+88FRV2froBsVEq7GhtKd9fRnB-0M2MD3a7tnSw@mail.gmail.com>
	<CAPQyPG6d3Sv26SiR6Xj4S5xOOy2DmrwQYO2wAwzrcg=2A0EcMQ@mail.gmail.com>
	<2109011.boM0eZ0ZTE@pawels>
Date: Fri, 21 Oct 2011 17:07:56 +0800
Message-ID: <CAPQyPG4SE8DyzuqwG74sE2zuZbDgfDoGDir1xHC3zdED+k=qLA@mail.gmail.com>
Subject: Re: kernel 3.0: BUG: soft lockup: find_get_pages+0x51/0x110
From: Nai Xia <nai.xia@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pawel Sikora <pluto@agmk.net>
Cc: Hugh Dickins <hughd@google.com>, arekm@pld-linux.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, jpiszcz@lucidpixels.com, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>

On Fri, Oct 21, 2011 at 4:07 PM, Pawel Sikora <pluto@agmk.net> wrote:
> On Friday 21 of October 2011 14:22:37 Nai Xia wrote:
>
>> And as a side note. Since I notice that Pawel's workload may include OOM=
,
>
> my last tests on patched (3.0.4 + migrate.c fix + vserver) kernel produce=
 full cpu load
> on dual 8-cores opterons like on this htop screenshot -> http://pluto.agm=
k.net/kernel/screen1.png
> afaics all userspace applications usualy don't use more than half of phys=
ical memory
> and so called "cache" on htop bar doesn't reach the 100%.

OK=EF=BC=8Cdid you logged any OOM killing if there was some memory usage bu=
rst?
But, well my above OOM reasoning is a direct short cut to imagined
root cause of "adjacent VMAs which
should have been merged but in fact not merged" case.
Maybe there are other cases that can lead to this or maybe it's
totally another bug....

But still I think if my reasoning is good, similar bad things will
happen again some time in the future,
even if it was not your case here...

>
> the patched kernel with disabled CONFIG_TRANSPARENT_HUGEPAGE (new thing i=
n 2.6.38)
> died at night, so now i'm going to disable also CONFIG_COMPACTION/MIGRATI=
ON in next
> steps and stress this machine again...

OK, it's smart to narrow down the range first....

>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
