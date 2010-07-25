Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 1493F6B02A4
	for <linux-mm@kvack.org>; Sun, 25 Jul 2010 12:40:13 -0400 (EDT)
Received: by iwn2 with SMTP id 2so2446281iwn.14
        for <linux-mm@kvack.org>; Sun, 25 Jul 2010 09:40:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100725184322.40CF.A69D9226@jp.fujitsu.com>
References: <20100723154638.88C8.A69D9226@jp.fujitsu.com>
	<AANLkTikpZ8iH1oO1k84kvo2qYYS96LYuNmmw6xJL-1QV@mail.gmail.com>
	<20100725184322.40CF.A69D9226@jp.fujitsu.com>
Date: Sun, 25 Jul 2010 22:10:12 +0530
Message-ID: <AANLkTinD8=XycQJ-yFBW_tJiE0kH70s2g2asfWtykEgL@mail.gmail.com>
Subject: Re: [PATCH 1/7] memcg: sc.nr_to_reclaim should be initialized
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nishimura Daisuke <d-nishimura@mtf.biglobe.ne.jp>
List-ID: <linux-mm.kvack.org>

On Sun, Jul 25, 2010 at 3:18 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> >> 1. How far does this push pages (in terms of when limit is hit)?
>> >
>> > 32 pages per mem_cgroup_shrink_node_zone().
>> >
>> > That said, the algorithm is here.
>> >
>> > 1. call mem_cgroup_largest_soft_limit_node()
>> > =A0 calculate largest cgroup
>> > 2. call mem_cgroup_shrink_node_zone() and shrink 32 pages
>> > 3. goto 1 if limit is still exceed.
>> >
>> > If it's not your intention, can you please your intended algorithm?
>>
>> We set it to 0, since we care only about a single page reclaim on
>> hitting the limit. IIRC, in the past we saw an excessive pushback on
>> reclaiming SWAP_CLUSTER_MAX pages, just wanted to check if you are
>> seeing the same behaviour even now after your changes.
>
> Actually, we have 32 pages reclaim batch size. (see nr_scan_try_batch() a=
nd related functions)
> thus <32 value doesn't works as your intended.
>
> But, If you run your test again, and (if there is) report any bugs. I'm v=
ery glad and fix it soon.
>

I understand that, the point is when to do stop the reclaim (do we
really need 32 pages to stop the reclaim, when we hit the limit,
something as low as a single page can help).  This is quite a subtle
thing, I'd mark it as low priority. I'll definitely come back if I see
unexpected behaviour.

Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
