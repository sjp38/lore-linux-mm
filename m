Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp06.au.ibm.com (8.13.1/8.13.1) with ESMTP id m7MMoTSI021081
	for <linux-mm@kvack.org>; Sat, 23 Aug 2008 08:50:29 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m7MMpBEZ262172
	for <linux-mm@kvack.org>; Sat, 23 Aug 2008 08:51:13 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m7MMpAHw030020
	for <linux-mm@kvack.org>; Sat, 23 Aug 2008 08:51:11 +1000
Message-ID: <48AF42DC.7020705@linux.vnet.ibm.com>
Date: Sat, 23 Aug 2008 04:21:08 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 1/14] memcg: unlimted root cgroup
References: <20080822202720.b7977aab.kamezawa.hiroyu@jp.fujitsu.com> <20080822203025.eb4b2ec3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080822203025.eb4b2ec3.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> Make root cgroup of memory resource controller to have no limit.
> 
> By this, users cannot set limit to root group. This is for making root cgroup
> as a kind of trash-can.
> 
> For accounting pages which has no owner, which are created by force_empty,
> we need some cgroup with no_limit. A patch for rewriting force_empty will
> will follow this one.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> ---
>  Documentation/controllers/memory.txt |    4 ++++
>  mm/memcontrol.c                      |   12 ++++++++++++
>  2 files changed, 16 insertions(+)
> 
> Index: mmtom-2.6.27-rc3+/mm/memcontrol.c
> ===================================================================
> --- mmtom-2.6.27-rc3+.orig/mm/memcontrol.c
> +++ mmtom-2.6.27-rc3+/mm/memcontrol.c
> @@ -133,6 +133,10 @@ struct mem_cgroup {
>  	 * statistics.
>  	 */
>  	struct mem_cgroup_stat stat;
> +	/*
> +	 * special flags.
> +	 */
> +	int	no_limit;

Is this a generic implementation to support no limits? If not, why not store the
root memory controller pointer and see if someone is trying to set a limit on that?

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
