Date: Wed, 14 Nov 2007 17:59:38 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][ for -mm] memory controller enhancements for NUMA [1/10]
 record nid/zid on page_cgroup
Message-Id: <20071114175938.89c2f854.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20071114174131.cf7c4aa6.kamezawa.hiroyu@jp.fujitsu.com>
References: <20071114173950.92857eaa.kamezawa.hiroyu@jp.fujitsu.com>
	<20071114174131.cf7c4aa6.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>
List-ID: <linux-mm.kvack.org>

On Wed, 14 Nov 2007 17:41:31 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> This patch adds nid/zoneid value to page cgroup.
> This helps per-zone accounting for memory cgroup and reclaim routine.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kmaezawa.hiroyu@jp.fujitsu.com>
Sigh...
kamezawa.hiroyu@jp.fujtsu.com..

Sorry,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
