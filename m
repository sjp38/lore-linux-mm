Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 36D076B0012
	for <linux-mm@kvack.org>; Mon, 23 May 2011 16:54:02 -0400 (EDT)
Received: from kpbe15.cbf.corp.google.com (kpbe15.cbf.corp.google.com [172.25.105.79])
	by smtp-out.google.com with ESMTP id p4NKrvgd005383
	for <linux-mm@kvack.org>; Mon, 23 May 2011 13:53:57 -0700
Received: from qwk3 (qwk3.prod.google.com [10.241.195.131])
	by kpbe15.cbf.corp.google.com with ESMTP id p4NKrVUN013922
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 23 May 2011 13:53:55 -0700
Received: by qwk3 with SMTP id 3so3035197qwk.19
        for <linux-mm@kvack.org>; Mon, 23 May 2011 13:53:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110523090816.3ab157d4.kamezawa.hiroyu@jp.fujitsu.com>
References: <1305928918-15207-1-git-send-email-yinghan@google.com>
	<20110523090816.3ab157d4.kamezawa.hiroyu@jp.fujitsu.com>
Date: Mon, 23 May 2011 13:53:55 -0700
Message-ID: <BANLkTikWT45NEQTArvwfb=DKYOmG3sL52Q@mail.gmail.com>
Subject: Re: [PATCH V5] memcg: add memory.numastat api for numa statistics
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

On Sun, May 22, 2011 at 5:08 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Fri, 20 May 2011 15:01:58 -0700
> Ying Han <yinghan@google.com> wrote:
>
>> The new API exports numa_maps per-memcg basis. This is a piece of useful
>> information where it exports per-memcg page distribution across real numa
>> nodes.
>>
>> One of the usecase is evaluating application performance by combining this
>> information w/ the cpu allocation to the application.
>>
>> The output of the memory.numastat tries to follow w/ simiar format of numa_maps
>> like:
>>
>> total=<total pages> N0=<node 0 pages> N1=<node 1 pages> ...
>> file=<total file pages> N0=<node 0 pages> N1=<node 1 pages> ...
>> anon=<total anon pages> N0=<node 0 pages> N1=<node 1 pages> ...
>> unevictable=<total anon pages> N0=<node 0 pages> N1=<node 1 pages> ...
>>
>
> Ah, please update Documentaion please.

Sure, will send out patch for the Documentation.

--Ying
>
> Thanks,
> -Kame
>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
