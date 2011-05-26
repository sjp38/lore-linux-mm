Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id B332B6B0011
	for <linux-mm@kvack.org>; Thu, 26 May 2011 12:56:12 -0400 (EDT)
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id p4QGuAYu005931
	for <linux-mm@kvack.org>; Thu, 26 May 2011 09:56:10 -0700
Received: from qwh5 (qwh5.prod.google.com [10.241.194.197])
	by wpaz24.hot.corp.google.com with ESMTP id p4QGtZXF021596
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 26 May 2011 09:56:09 -0700
Received: by qwh5 with SMTP id 5so633896qwh.34
        for <linux-mm@kvack.org>; Thu, 26 May 2011 09:56:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110526090538.GA19082@cmpxchg.org>
References: <1305583230-2111-1-git-send-email-yinghan@google.com>
	<20110516231512.GW16531@cmpxchg.org>
	<BANLkTinohFTQRTViyU5NQ6EGi95xieXwOA@mail.gmail.com>
	<20110516171820.124a8fbc.akpm@linux-foundation.org>
	<20110526090538.GA19082@cmpxchg.org>
Date: Thu, 26 May 2011 09:56:06 -0700
Message-ID: <BANLkTin=nYuGiGzgNB0ZdLVPA_wotxvAEg@mail.gmail.com>
Subject: Re: [PATCH] memcg: fix typo in the soft_limit stats.
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

On Thu, May 26, 2011 at 2:05 AM, Johannes Weiner <hannes@cmpxchg.org> wrote=
:
> On Mon, May 16, 2011 at 05:18:20PM -0700, Andrew Morton wrote:
>> On Mon, 16 May 2011 17:05:02 -0700
>> Ying Han <yinghan@google.com> wrote:
>>
>> > On Mon, May 16, 2011 at 4:15 PM, Johannes Weiner <hannes@cmpxchg.org> =
wrote:
>> >
>> > > On Mon, May 16, 2011 at 03:00:30PM -0700, Ying Han wrote:
>> > > > This fixes the typo in the memory.stat including the following two
>> > > > stats:
>> > > >
>> > > > $ cat /dev/cgroup/memory/A/memory.stat
>> > > > total_soft_steal 0
>> > > > total_soft_scan 0
>> > > >
>> > > > And change it to:
>> > > >
>> > > > $ cat /dev/cgroup/memory/A/memory.stat
>> > > > total_soft_kswapd_steal 0
>> > > > total_soft_kswapd_scan 0
>> > > >
>> > > > Signed-off-by: Ying Han <yinghan@google.com>
>> > >
>> > > I am currently proposing and working on a scheme that makes the soft
>> > > limit not only a factor for global memory pressure, but for
>> > > hierarchical reclaim in general, to prefer child memcgs during recla=
im
>> > > that are in excess of their soft limit.
>> > >
>> > > Because this means prioritizing memcgs over one another, rather than
>> > > having explicit soft limit reclaim runs, there is no natural counter
>> > > for pages reclaimed due to the soft limit anymore.
>> > >
>> > > Thus, for the patch that introduces this counter:
>> > >
>> > > Nacked-by: Johannes Weiner <hannes@cmpxchg.org>
>> > >
>> >
>> > This patch is fixing a typo of the stats being integrated into mmotm. =
Does
>> > it make sense to fix the
>> > existing stats first while we are discussing other approaches?
>> >
>>
>> It would be quite bad to add new userspace-visible stats and to then
>> take them away again.
>>
>> But given that memcg-add-stats-to-monitor-soft_limit-reclaim.patch is
>> queued for 2.6.39-rc1, we could proceed with that plan and then make
>> sure that Johannes's changes are merged either prior to 2.6.40 or
>> they are never merged at all.
>
> I am on it, but I don't think I can get them into shape and
> rudimentally benchmarked until the merge window is closed.
>
> So far I found nothing that would invalidate the design or have
> measurable impact on non-memcg systems. =A0Then again, I suck at
> constructing tests, and have only limited machinery available.
>
> If people are interested and would like to help out verifying the
> changes, I can send an updated and documented version of the series
> that should be easier to understand.

Please do. I can help test it out.

--Ying

>
>> Or we could just leave out the stats until we're sure. =A0Not having the=
m
>> for a while is not as bad as adding them and then removing them.
>
> I am a bit unsure as to why there is a sudden rush with those
> statistics now.

>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
