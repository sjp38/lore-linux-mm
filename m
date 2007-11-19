Date: Mon, 19 Nov 2007 10:48:26 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] memory controller per zone patches take 2 [9/10]
 per-zone-lru for memory cgroup
Message-Id: <20071119104826.e4ba02ca.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <473F2A1A.8000703@linux.vnet.ibm.com>
References: <20071116191107.46dd523a.kamezawa.hiroyu@jp.fujitsu.com>
	<20071116192642.8c7f07c9.kamezawa.hiroyu@jp.fujitsu.com>
	<473F2A1A.8000703@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "containers@lists.osdl.org" <containers@lists.osdl.org>
List-ID: <linux-mm.kvack.org>

On Sat, 17 Nov 2007 23:21:22 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> Thanks, this has been a long pending TODO. What is pending now on my
> plate is re-organizing res_counter to become aware of the filesystem
> hierarchy. I want to split out the LRU lists from the memory controller
> and resource counters.
> 
Does "file system hierarchy" here means "control group hierarchy" ?
like
=
/cgroup/group_A/group_A_1
            .  /group_A_2
               /group_A_3
(LRU(s) will be used for maintaining parent/child groups.)


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
