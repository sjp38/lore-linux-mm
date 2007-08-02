Date: Thu, 2 Aug 2007 12:52:43 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: NUMA policy issues with ZONE_MOVABLE
In-Reply-To: <20070802194211.GE23133@skynet.ie>
Message-ID: <Pine.LNX.4.64.0708021251180.8527@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0707242120370.3829@schroedinger.engr.sgi.com>
 <20070725111646.GA9098@skynet.ie> <Pine.LNX.4.64.0707251212300.8820@schroedinger.engr.sgi.com>
 <20070802140904.GA16940@skynet.ie> <Pine.LNX.4.64.0708021152370.7719@schroedinger.engr.sgi.com>
 <20070802194211.GE23133@skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: linux-mm@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, ak@suse.de, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, akpm@linux-foundation.org, pj@sgi.com
List-ID: <linux-mm.kvack.org>

On Thu, 2 Aug 2007, Mel Gorman wrote:

> 
> --- 
> diff --git a/drivers/base/node.c b/drivers/base/node.c
> index cae346e..3656489 100644
> --- a/drivers/base/node.c
> +++ b/drivers/base/node.c
> @@ -98,6 +98,7 @@ static SYSDEV_ATTR(meminfo, S_IRUGO, node_read_meminfo, NULL);
>  
>  static ssize_t node_read_numastat(struct sys_device * dev, char * buf)
>  {
> +	refresh_all_cpu_vm_stats();

The function is called refresh_vmstats(). Just export it.

>  		       "numa_miss %lu\n"
> diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
> index 75370ec..31046e2 100644
> --- a/include/linux/vmstat.h
> +++ b/include/linux/vmstat.h
> @@ -213,6 +213,7 @@ extern void dec_zone_state(struct zone *, enum zone_stat_item);
>  extern void __dec_zone_state(struct zone *, enum zone_stat_item);
>  
>  void refresh_cpu_vm_stats(int);
> +void refresh_all_cpu_vm_stats(void);

No need to add another one.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
