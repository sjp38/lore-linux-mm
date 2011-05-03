Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 03B7D6B0012
	for <linux-mm@kvack.org>; Tue,  3 May 2011 12:59:17 -0400 (EDT)
Received: from hpaq11.eem.corp.google.com (hpaq11.eem.corp.google.com [172.25.149.11])
	by smtp-out.google.com with ESMTP id p43Gx9e8006481
	for <linux-mm@kvack.org>; Tue, 3 May 2011 09:59:09 -0700
Received: from gyh20 (gyh20.prod.google.com [10.243.50.212])
	by hpaq11.eem.corp.google.com with ESMTP id p43GwWx4029417
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 3 May 2011 09:59:08 -0700
Received: by gyh20 with SMTP id 20so133805gyh.8
        for <linux-mm@kvack.org>; Tue, 03 May 2011 09:59:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4DC0092D.2060902@redhat.com>
References: <1304355025-1421-1-git-send-email-yinghan@google.com>
	<1304355025-1421-3-git-send-email-yinghan@google.com>
	<4DC0092D.2060902@redhat.com>
Date: Tue, 3 May 2011 09:59:07 -0700
Message-ID: <BANLkTikw09E1ojhxMeqb38wjsnRYzwYfhg@mail.gmail.com>
Subject: Re: [PATCH V2 2/2] Add stats to monitor soft_limit reclaim
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

On Tue, May 3, 2011 at 6:54 AM, Rik van Riel <riel@redhat.com> wrote:
> On 05/02/2011 12:50 PM, Ying Han wrote:
>>
>> This patch extend the soft_limit reclaim stats to both global background
>> reclaim and global direct reclaim.
>>
>> The following stats are renamed and added:
>>
>> $cat /dev/cgroup/memory/A/memory.stat
>> soft_kswapd_steal 1053626
>> soft_kswapd_scan 1053693
>> soft_direct_steal 1481810
>> soft_direct_scan 1481996
>>
>> changelog v2..v1:
>> 1. rename the stats on soft_kswapd/direct_steal/scan.
>> 2. fix the documentation to match the stat name.
>
>> Signed-off-by: Ying Han<yinghan@google.com>
>
> Acked-by: Rik van Riel<riel@redhat.com>
>
> I expect people to continue arguing over the names a little
> longer, but feel free to keep my Acked-by: across the various
> name changes :)

Hi Rik:

Thank you for reviewing and acking. Regarding the name, i think we are
reaching some stage. And my
current naming is following that as well. :)

--Ying
>
> --
> All rights reversed
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
