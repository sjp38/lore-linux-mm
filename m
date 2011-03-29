Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3B2738D0040
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 18:13:44 -0400 (EDT)
Received: by iwg8 with SMTP id 8so846181iwg.14
        for <linux-mm@kvack.org>; Tue, 29 Mar 2011 15:13:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110329190520.GJ12265@random.random>
References: <1301373398.2590.20.camel@mulgrave.site>
	<4D91FC2D.4090602@redhat.com>
	<20110329190520.GJ12265@random.random>
Date: Wed, 30 Mar 2011 07:13:42 +0900
Message-ID: <BANLkTikDwfQaSGtrKOSvgA9oaRC1Lbx3cw@mail.gmail.com>
Subject: Re: [Lsf] [LSF][MM] page allocation & direct reclaim latency
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Rik van Riel <riel@redhat.com>, lsf@lists.linux-foundation.org, linux-mm <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Wed, Mar 30, 2011 at 4:05 AM, Andrea Arcangeli <aarcange@redhat.com> wro=
te:
> Hi Rik, Hugh and everyone,
>
> On Tue, Mar 29, 2011 at 11:35:09AM -0400, Rik van Riel wrote:
>> On 03/29/2011 12:36 AM, James Bottomley wrote:
>> > Hi All,
>> >
>> > Since LSF is less than a week away, the programme committee put togeth=
er
>> > a just in time preliminary agenda for LSF. =C2=A0As you can see there =
is
>> > still plenty of empty space, which you can make suggestions
>>
>> There have been a few patches upstream by people for who
>> page allocation latency is a concern.
>>
>> It may be worthwhile to have a short discussion on what
>> we can do to keep page allocation (and direct reclaim?)
>> latencies down to a minimum, reducing the slowdown that
>> direct reclaim introduces on some workloads.
>
> I don't see the patches you refer to, but checking schedule we've a
> slot with Mel&Minchan about "Reclaim, compaction and LRU
> ordering". Compaction only applies to high order allocations and it
> changes nothing to PAGE_SIZE allocations, but it surely has lower
> latency than the older lumpy reclaim logic so overall it should be a
> net improvement compared to what we had before.
>
> Should the latency issues be discussed in that track?

It's okay to me. LRU ordering issue wouldn't take much time.
But I am not sure Mel would have a long time. :)

About reclaim latency, I sent a patch in the old days.
http://marc.info/?l=3Dlinux-mm&m=3D129187231129887&w=3D4

And some guys on embedded had a concern about latency.
They want OOM rather than eviction of working set and undeterministic
latency of reclaim.

As another issue of related to latency, there is a OOM.
To accelerate task's exit, we raise a priority of the victim process
but it had a problem so Kosaki decided reverting the patch. It's
totally related to latency issue but it would

In addition, Kame and I sent a patch to prevent forkbomb. Kame's
apprach is to track the history of mm and mine is to use sysrq to kill
recently created tasks. The approaches have pros and cons.
But anyone seem to not has a interest about forkbomb protection.
So I want to listen other's opinion we really need it

I am not sure this could become a topic of LSF/MM
If it is proper, I would like to talk above issues in "Reclaim,
compaction and LRU ordering" slot.

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
