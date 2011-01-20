Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id C7FCA6B0092
	for <linux-mm@kvack.org>; Wed, 19 Jan 2011 19:59:16 -0500 (EST)
Received: by iwn40 with SMTP id 40so49007iwn.14
        for <linux-mm@kvack.org>; Wed, 19 Jan 2011 16:59:03 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1101191212090.19519@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1101172108380.29048@chino.kir.corp.google.com>
	<AANLkTin036LNAJ053ByMRmQUnsBpRcv1s5uX1j_2c_Ds@mail.gmail.com>
	<alpine.DEB.2.00.1101181751420.25382@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1101191351010.20403@router.home>
	<20110119200625.GD15568@one.firstfloor.org>
	<alpine.DEB.2.00.1101191212090.19519@chino.kir.corp.google.com>
Date: Thu, 20 Jan 2011 09:59:03 +0900
Message-ID: <AANLkTi=UDM5bjOS+51CHRDMcouT6Q9kEaRxCJL4TS2gN@mail.gmail.com>
Subject: Re: [patch] mm: fix deferred congestion timeout if preferred zone is
 not allowed
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andi Kleen <andi@firstfloor.org>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 20, 2011 at 5:18 AM, David Rientjes <rientjes@google.com> wrote=
:
> On Wed, 19 Jan 2011, Andi Kleen wrote:
>
>> cpusets didn't exist when I designed that. But the idea was that
>> the kernel has a first choice ("hit") and any other node is a "miss"
>> that may need investigation. =A0So yes I would consider cpuset config as=
 an
>> intention too and should be counted as hit/miss.
>>
>
> Ok, so there's no additional modification that needs to be made with the
> patch (other than perhaps some more descriptive documentation of a
> NUMA_HIT and NUMA_MISS). =A0When the kernel passes all zones into the pag=
e
> allocator, it's relying on cpusets to reduce that zonelist to only
> allowable nodes by using ALLOC_CPUSET. =A0If we can allocate from the fir=
st
> zone allowed by the cpuset, it will be treated as a hit; otherwise, it
> will be treated as a miss. =A0That's better than treating everything as a
> miss when the cpuset doesn't include the first node.
>

Thanks for the care on this issue, David, Christoph, Andi.
Looks good to me.
Feel free to add my Reviewed-by.

Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
