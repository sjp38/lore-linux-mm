Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id B40808D0040
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 16:35:39 -0400 (EDT)
Received: from hpaq5.eem.corp.google.com (hpaq5.eem.corp.google.com [172.25.149.5])
	by smtp-out.google.com with ESMTP id p2TKZRPe008020
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 13:35:27 -0700
Received: from qwi4 (qwi4.prod.google.com [10.241.195.4])
	by hpaq5.eem.corp.google.com with ESMTP id p2TKZEet013228
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 13:35:25 -0700
Received: by qwi4 with SMTP id 4so847034qwi.1
        for <linux-mm@kvack.org>; Tue, 29 Mar 2011 13:35:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110329190520.GJ12265@random.random>
References: <1301373398.2590.20.camel@mulgrave.site>
	<4D91FC2D.4090602@redhat.com>
	<20110329190520.GJ12265@random.random>
Date: Tue, 29 Mar 2011 13:35:24 -0700
Message-ID: <BANLkTi=cysSDYUaRX3nXHgKmEB9acjCMsA@mail.gmail.com>
Subject: Re: [Lsf] [LSF][MM] page allocation & direct reclaim latency
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>
Cc: lsf@lists.linux-foundation.org, linux-mm <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>

On Tue, Mar 29, 2011 at 12:05 PM, Andrea Arcangeli <aarcange@redhat.com> wr=
ote:
> Hi Rik, Hugh and everyone,
>
> On Tue, Mar 29, 2011 at 11:35:09AM -0400, Rik van Riel wrote:
>> On 03/29/2011 12:36 AM, James Bottomley wrote:
>> > Hi All,
>> >
>> > Since LSF is less than a week away, the programme committee put togeth=
er
>> > a just in time preliminary agenda for LSF. =A0As you can see there is
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
>
> The MM schedule has still a free slot 14-14:30 on Monday, I wonder if
> there's interest on a "NUMA automatic migration and scheduling
> awareness" topic or if it's still too vapourware for a real topic and
> we should keep it for offtrack discussions, and maybe we should
> reserve it for something more tangible with patches already floating
> around. Comments welcome.


In page reclaim, I would like to discuss on the magic "8" *
high_wmark() in balance_pgdat(). I recently found the discussion on
thread "too big min_free_kbytes", where I didn't find where we proved
it is still a problem or not. This might not need reserve time slot,
but something I want to learn more on.

--Ying


>
> Thanks,
> Andrea
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
