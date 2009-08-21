Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 19C106B0087
	for <linux-mm@kvack.org>; Fri, 21 Aug 2009 12:36:46 -0400 (EDT)
Received: by gxk12 with SMTP id 12so1198309gxk.4
        for <linux-mm@kvack.org>; Fri, 21 Aug 2009 09:36:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090820040533.GA27540@localhost>
References: <20090820024929.GA19793@localhost>
	 <20090820121347.8a886e4b.kamezawa.hiroyu@jp.fujitsu.com>
	 <20090820040533.GA27540@localhost>
Date: Fri, 21 Aug 2009 12:55:27 +0900
Message-ID: <28c262360908202055u2744879cic989e007867d0599@mail.gmail.com>
Subject: Re: [PATCH -v2] mm: do batched scans for mem_cgroup
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Avi Kivity <avi@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Dike, Jeffrey G" <jeffrey.g.dike@intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "menage@google.com" <menage@google.com>
List-ID: <linux-mm.kvack.org>

On Thu, Aug 20, 2009 at 1:05 PM, Wu Fengguang<fengguang.wu@intel.com> wrote=
:
> On Thu, Aug 20, 2009 at 11:13:47AM +0800, KAMEZAWA Hiroyuki wrote:
>> On Thu, 20 Aug 2009 10:49:29 +0800
>> Wu Fengguang <fengguang.wu@intel.com> wrote:
>>
>> > For mem_cgroup, shrink_zone() may call shrink_list() with nr_to_scan=
=3D1,
>> > in which case shrink_list() _still_ calls isolate_pages() with the muc=
h
>> > larger SWAP_CLUSTER_MAX. =C2=A0It effectively scales up the inactive l=
ist
>> > scan rate by up to 32 times.
>> >
>> > For example, with 16k inactive pages and DEF_PRIORITY=3D12, (16k >> 12=
)=3D4.
>> > So when shrink_zone() expects to scan 4 pages in the active/inactive
>> > list, it will be scanned SWAP_CLUSTER_MAX=3D32 pages in effect.
>> >
>> > The accesses to nr_saved_scan are not lock protected and so not 100%
>> > accurate, however we can tolerate small errors and the resulted small
>> > imbalanced scan rates between zones.
>> >
>> > This batching won't blur up the cgroup limits, since it is driven by
>> > "pages reclaimed" rather than "pages scanned". When shrink_zone()
>> > decides to cancel (and save) one smallish scan, it may well be called
>> > again to accumulate up nr_saved_scan.
>> >
>> > It could possibly be a problem for some tiny mem_cgroup (which may be
>> > _full_ scanned too much times in order to accumulate up nr_saved_scan)=
.
>> >
>> > CC: Rik van Riel <riel@redhat.com>
>> > CC: Minchan Kim <minchan.kim@gmail.com>
>> > CC: Balbir Singh <balbir@linux.vnet.ibm.com>
>> > CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>> > CC: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> > Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

It looks better than now :)

I hope you will rewrite description and add test result in changelog. :)
Thanks for your great effort.

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
