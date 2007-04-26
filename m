Date: Thu, 26 Apr 2007 15:00:49 -0500
From: Dean Nelson <dcn@sgi.com>
Subject: Re: slab allocators: Remove multiple alignment specifications.
Message-ID: <20070426200049.GA1566@sgi.com>
References: <Pine.LNX.4.64.0704202210060.17036@schroedinger.engr.sgi.com> <20070420223727.7b201984.akpm@linux-foundation.org> <Pine.LNX.4.64.0704202243480.25004@schroedinger.engr.sgi.com> <20070420231129.9252ca67.akpm@linux-foundation.org> <Pine.LNX.4.64.0704202330440.11938@schroedinger.engr.sgi.com> <20070423154412.GA12733@lnx-holt.americas.sgi.com> <Pine.LNX.4.64.0704230849110.10624@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0704230849110.10624@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: clameter@sgi.com, holt@sgi.com, tony.luck@intel.com, linux-mm@kvack.org, dcn@sgi.com
List-ID: <linux-mm.kvack.org>

On Mon, Apr 23, 2007 at 08:53:09AM -0700, Christoph Lameter wrote:
> On Mon, 23 Apr 2007, Robin Holt wrote:
> 
> > On Fri, Apr 20, 2007 at 11:32:48PM -0700, Christoph Lameter wrote:
> > > Well xpmem is broke and readahead is failing all over the place. Some 
> > > patches missing?
> > 
> > Which xpmem are you compiling?  Did you let Dean Nelson know about this?
> > Has anything been submitted to the community yet?
> 
> I think this was just a an artifact of an inconsistent ia64 mix of 
> patches in a temporary tree by Andrew.
> 
> Here is the hack that I used to compile more of the temp tree.
> 
> 
> Index: linux-2.6.21-rc7/arch/ia64/sn/kernel/xpc_main.c
> ===================================================================
> --- linux-2.6.21-rc7.orig/arch/ia64/sn/kernel/xpc_main.c	2007-04-20 23:23:31.000000000 -0700
> +++ linux-2.6.21-rc7/arch/ia64/sn/kernel/xpc_main.c	2007-04-20 23:25:32.000000000 -0700
> @@ -811,6 +811,8 @@ xpc_create_kthreads(struct xpc_channel *
>  	pid_t pid;
>  	u64 args = XPC_PACK_ARGS(ch->partid, ch->number);
>  	struct xpc_partition *part = &xpc_partitions[ch->partid];
> +	struct task_struct *task;
> +
>  
>  
>  	while (needed-- > 0) {
> @@ -839,7 +841,7 @@ xpc_create_kthreads(struct xpc_channel *
>  		xpc_msgqueue_ref(ch);
>  
>  		task = kthread_run(xpc_daemonize_kthread, args,
> -				   "xpc%02dc%d", partid, ch_number);
> +				   "xpc%02dc%d", ch->partid, ch->number);
>  		if (IS_ERR(task)) {
>  			/* the fork failed */
>  

Acked-by: Dean Nelson <dcn@sgi.com>

Andrew, this patch is a proper fix for a couple of compiler errors introduced
by a patch entitled ia64-sn-xpc-convert-to-use-kthread-api. You called the
following patch ia64-sn-xpc-convert-to-use-kthread-api-fix.

Thanks,
Dean

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
