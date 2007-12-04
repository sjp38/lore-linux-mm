Date: Tue, 4 Dec 2007 15:46:20 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][for -mm] memory controller enhancements for reclaiming
 take2 [0/8] introduction
Message-Id: <20071204154620.72a17f73.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20071203183355.0061ddeb.kamezawa.hiroyu@jp.fujitsu.com>
References: <20071203183355.0061ddeb.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>, Andrew Morton <akpm@linux-foundation.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

On Mon, 3 Dec 2007 18:33:55 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> [Patches]
> [1/8] ... remove unused variable (clean up)
> [2/8] ... change 'if' sentense to BUG_ON() (clean up)
> [3/8] ... add free_mem_cgroup_per_zone_info (clean up)
> [4/8] ... possible race fix in resource controler
> [5/8] ... throttling simultaneous direct reclaim under cgroup
> [6/8] ... high/low watermark for resource controler
> [7/8] ... use high/low watermark in memory controler
> [8/8] ... wake up reclaim waiters at unchage.
> 

Hi, Andrew. I think patch 5-8 should be got more review and discussion.

I'd like to schedule them to the next -mm. (because rc4 is shipped...)
But patch 1-4 are just clean up and bug fix and seems no side-effect.

Could you pick up 1-4 to -mm if Balbir and Pavel gives me ack ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
