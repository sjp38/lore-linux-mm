Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2F3966B0023
	for <linux-mm@kvack.org>; Wed,  4 May 2011 03:33:35 -0400 (EDT)
Received: by wyf19 with SMTP id 19so834757wyf.14
        for <linux-mm@kvack.org>; Wed, 04 May 2011 00:33:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110504040018.GB6500@localhost>
References: <BANLkTik8k9A8N8CPk+eXo9c_syxJFRyFCA@mail.gmail.com>
	<BANLkTim0MNgqeh1KTfvpVFuAvebKyQV8Hg@mail.gmail.com>
	<20110426062535.GB19717@localhost>
	<BANLkTinM9DjK9QsGtN0Sh308rr+86UMF0A@mail.gmail.com>
	<20110426063421.GC19717@localhost>
	<BANLkTi=xDozFNBXNdGDLK6EwWrfHyBifQw@mail.gmail.com>
	<20110426092029.GA27053@localhost>
	<20110426124743.e58d9746.akpm@linux-foundation.org>
	<20110428133644.GA12400@localhost>
	<BANLkTimpT-N5--3QjcNg8CyNNwfEWxFyKA@mail.gmail.com>
	<20110504040018.GB6500@localhost>
Date: Wed, 4 May 2011 15:33:32 +0800
Message-ID: <BANLkTimCK9kxrepvvCjXDNEhWaX2sxC5zA@mail.gmail.com>
Subject: Re: [RFC][PATCH] mm: cut down __GFP_NORETRY page allocation failures
From: Dave Young <hidave.darkstar@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Mel Gorman <mel@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Dave Chinner <david@fromorbit.com>, David Rientjes <rientjes@google.com>

On Wed, May 4, 2011 at 12:00 PM, Wu Fengguang <fengguang.wu@intel.com> wrot=
e:
>> > CAL: =C2=A0 =C2=A0 220449 =C2=A0 =C2=A0 220246 =C2=A0 =C2=A0 220372 =
=C2=A0 =C2=A0 220558 =C2=A0 =C2=A0 220251 =C2=A0 =C2=A0 219740 =C2=A0 =C2=
=A0 220043 =C2=A0 =C2=A0 219968 =C2=A0 Function call interrupts
>> >
>> > LOC: =C2=A0 =C2=A0 536274 =C2=A0 =C2=A0 532529 =C2=A0 =C2=A0 531734 =
=C2=A0 =C2=A0 536801 =C2=A0 =C2=A0 536510 =C2=A0 =C2=A0 533676 =C2=A0 =C2=
=A0 534853 =C2=A0 =C2=A0 532038 =C2=A0 Local timer interrupts
>> > RES: =C2=A0 =C2=A0 =C2=A0 3032 =C2=A0 =C2=A0 =C2=A0 2128 =C2=A0 =C2=A0=
 =C2=A0 1792 =C2=A0 =C2=A0 =C2=A0 1765 =C2=A0 =C2=A0 =C2=A0 2184 =C2=A0 =C2=
=A0 =C2=A0 1703 =C2=A0 =C2=A0 =C2=A0 1754 =C2=A0 =C2=A0 =C2=A0 1865 =C2=A0 =
Rescheduling interrupts
>> > TLB: =C2=A0 =C2=A0 =C2=A0 =C2=A0189 =C2=A0 =C2=A0 =C2=A0 =C2=A0 15 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 13 =C2=A0 =C2=A0 =C2=A0 =C2=A0 17 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 64 =C2=A0 =C2=A0 =C2=A0 =C2=A0294 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 97 =C2=A0 =C2=A0 =C2=A0 =C2=A0 63 =C2=A0 TLB shootdowns
>>
>> Could you tell how to get above info?
>
> It's /proc/interrupts.
>
> I have two lines at the end of the attached script to collect the
> information, and another script to call getdelays on every 10s. The
> posted reclaim delays are the last successful getdelays output.
>
> I've automated the test process, so that with one single command line
> a new kernel will be built and the test box will rerun tests on the
> new kernel :)

Thank you for that effort!

>
> Thanks,
> Fengguang
>



--=20
Regards
dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
