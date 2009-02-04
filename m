Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 904706B003D
	for <linux-mm@kvack.org>; Wed,  4 Feb 2009 01:49:44 -0500 (EST)
Message-ID: <49893A5A.7000506@cn.fujitsu.com>
Date: Wed, 04 Feb 2009 14:48:58 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [-mm patch] Show memcg information during OOM (v3)
References: <20090203172135.GF918@balbir.in.ibm.com> <4988E727.8030807@cn.fujitsu.com> <20090204033750.GB4456@balbir.in.ibm.com> <20090204142455.83c38ad6.kamezawa.hiroyu@jp.fujitsu.com> <20090204064249.GC4456@balbir.in.ibm.com>
In-Reply-To: <20090204064249.GC4456@balbir.in.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

>> BTW, I wonder can't we show the path of mount point ?
>> /group_A/01 is /cgroup/group_A/01 and /group_A/ is /cgroup/group_A/ on this system.
>> Very difficult ?
>>
> 
> No, it is not very difficult, we just need to append the mount point.
> The reason for not doing it is consistency with output of
> /proc/<pid>/cgroup and other places where cgroup_path prints the path
> relative to the mount point. Since we are talking about memory, the
> administrator should know where it is mounted. Do you strongly feel
> the need to add mount point? My concern is consistency with other
> cgroup output (look at /proc/sched_debug) for example.
> 

Another reason to not do so is, we can mount a specific hierarchy to
multiple mount points.
	# mount -t cgroup -o memory /mnt
	# mount -t cgroup -o memory /cgroup
	# mkdir /mnt/0
Now, /mnt/0 is the same with /cgroup/0.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
