Date: Thu, 15 Nov 2007 20:36:45 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][ for -mm] memory controller enhancements for NUMA [10/10]
 per-zone-lru
Message-Id: <20071115203645.db9d36be.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20071114175737.d5066644.kamezawa.hiroyu@jp.fujitsu.com>
References: <20071114173950.92857eaa.kamezawa.hiroyu@jp.fujitsu.com>
	<20071114175737.d5066644.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Wed, 14 Nov 2007 17:57:37 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> I think there is a consensus that memory controller needs per-zone lru.
> But it was postphoned that it seems some people tries to modify lru of zones.
> 
> Now, "scan" value, in mem_cgroup_isolate_pages(), handling is fixed. So,
> demand of implementing per-zone-lru is raised.
> 
> This patch implements per-zone lru for memory cgroup.
> I think this patch's style implementation can be adjusted to zone's lru 
> implementation changes if happens.
>

I noticed this patch doesn't handle memory migration in sane way.
I will fix in the next version.

-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
