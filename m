Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f200.google.com (mail-lb0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id C24A66B0253
	for <linux-mm@kvack.org>; Wed, 22 Jun 2016 22:47:48 -0400 (EDT)
Received: by mail-lb0-f200.google.com with SMTP id c1so50837180lbw.0
        for <linux-mm@kvack.org>; Wed, 22 Jun 2016 19:47:48 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id t123si1772450wma.52.2016.06.22.19.47.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Jun 2016 19:47:47 -0700 (PDT)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u5N2i0P5131277
	for <linux-mm@kvack.org>; Wed, 22 Jun 2016 22:47:46 -0400
Received: from e34.co.us.ibm.com (e34.co.us.ibm.com [32.97.110.152])
	by mx0a-001b2d01.pphosted.com with ESMTP id 23q9nc8c97-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 22 Jun 2016 22:47:46 -0400
Received: from localhost
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Wed, 22 Jun 2016 20:47:45 -0600
Received: from b01cxnp22035.gho.pok.ibm.com (b01cxnp22035.gho.pok.ibm.com [9.57.198.25])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id DAACB3E40048
	for <linux-mm@kvack.org>; Wed, 22 Jun 2016 20:47:43 -0600 (MDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by b01cxnp22035.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u5N2lhFf58785818
	for <linux-mm@kvack.org>; Thu, 23 Jun 2016 02:47:43 GMT
Received: from d01av01.pok.ibm.com (localhost [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u5N2lhH7016958
	for <linux-mm@kvack.org>; Wed, 22 Jun 2016 22:47:43 -0400
Date: Wed, 22 Jun 2016 19:47:42 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: Boot failure on emev2/kzm9d (was: Re: [PATCH v2 11/11] mm/slab:
 lockless decision to grow cache)
Reply-To: paulmck@linux.vnet.ibm.com
References: <CAMuHMdVi-F0n-GjnUqEEd58UcWxw67g8ZJO838fvo31Ttr5E1g@mail.gmail.com>
 <20160620063942.GA13747@js1304-P5Q-DELUXE>
 <20160620131254.GO3923@linux.vnet.ibm.com>
 <20160621064302.GA20635@js1304-P5Q-DELUXE>
 <20160621125406.GF3923@linux.vnet.ibm.com>
 <20160622005208.GB25106@js1304-P5Q-DELUXE>
 <CAMuHMdW-wSxASozhmPh0b+9UJFFVbYHqTqH5e9P1oO7T59YE7g@mail.gmail.com>
 <20160622190859.GA1473@linux.vnet.ibm.com>
 <20160623004935.GA20752@linux.vnet.ibm.com>
 <20160623023756.GA30438@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160623023756.GA30438@js1304-P5Q-DELUXE>
Message-Id: <20160623024742.GD1473@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-renesas-soc@vger.kernel.org, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On Thu, Jun 23, 2016 at 11:37:56AM +0900, Joonsoo Kim wrote:
> On Wed, Jun 22, 2016 at 05:49:35PM -0700, Paul E. McKenney wrote:
> > On Wed, Jun 22, 2016 at 12:08:59PM -0700, Paul E. McKenney wrote:
> > > On Wed, Jun 22, 2016 at 05:01:35PM +0200, Geert Uytterhoeven wrote:
> > > > On Wed, Jun 22, 2016 at 2:52 AM, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> > > > > Could you try below patch to check who causes the hang?
> > > > >
> > > > > And, if sysalt-t works when hang, could you get sysalt-t output? I haven't
> > > > > used it before but Paul could find some culprit on it. :)
> > > > >
> > > > > Thanks.
> > > > >
> > > > >
> > > > > ----->8-----
> > > > > diff --git a/mm/slab.c b/mm/slab.c
> > > > > index 763096a..9652d38 100644
> > > > > --- a/mm/slab.c
> > > > > +++ b/mm/slab.c
> > > > > @@ -964,8 +964,13 @@ static int setup_kmem_cache_node(struct kmem_cache *cachep,
> > > > >          * guaranteed to be valid until irq is re-enabled, because it will be
> > > > >          * freed after synchronize_sched().
> > > > >          */
> > > > > -       if (force_change)
> > > > > +       if (force_change) {
> > > > > +               if (num_online_cpus() > 1)
> > > > > +                       dump_stack();
> > > > >                 synchronize_sched();
> > > > > +               if (num_online_cpus() > 1)
> > > > > +                       dump_stack();
> > > > > +       }
> > > > 
> > > > I've only added the first one, as I would never see the second one. All of
> > > > this happens before the serial console is activated, earlycon is not supported,
> > > > and I only have remote access.
> > > > 
> > > > Brought up 2 CPUs
> > > > SMP: Total of 2 processors activated (2132.00 BogoMIPS).
> > > > CPU: All CPU(s) started in SVC mode.
> > > > CPU: 0 PID: 1 Comm: swapper/0 Not tainted
> > > > 4.7.0-rc4-kzm9d-00404-g4a235e6dde4404dd-dirty #89
> > > > Hardware name: Generic Emma Mobile EV2 (Flattened Device Tree)
> > > > [<c010de68>] (unwind_backtrace) from [<c010a658>] (show_stack+0x10/0x14)
> > > > [<c010a658>] (show_stack) from [<c02b5cf8>] (dump_stack+0x7c/0x9c)
> > > > [<c02b5cf8>] (dump_stack) from [<c01cfa4c>] (setup_kmem_cache_node+0x140/0x170)
> > > > [<c01cfa4c>] (setup_kmem_cache_node) from [<c01cfe3c>]
> > > > (__do_tune_cpucache+0xf4/0x114)
> > > > [<c01cfe3c>] (__do_tune_cpucache) from [<c01cff54>] (enable_cpucache+0xf8/0x148)
> > > > [<c01cff54>] (enable_cpucache) from [<c01d0190>]
> > > > (__kmem_cache_create+0x1a8/0x1d0)
> > > > [<c01d0190>] (__kmem_cache_create) from [<c01b32d0>]
> > > > (kmem_cache_create+0xbc/0x190)
> > > > [<c01b32d0>] (kmem_cache_create) from [<c070d968>] (shmem_init+0x34/0xb0)
> > > > [<c070d968>] (shmem_init) from [<c0700cc8>] (kernel_init_freeable+0x98/0x1ec)
> > > > [<c0700cc8>] (kernel_init_freeable) from [<c049fdbc>] (kernel_init+0x8/0x110)
> > > > [<c049fdbc>] (kernel_init) from [<c0106cb8>] (ret_from_fork+0x14/0x3c)
> > > > devtmpfs: initialized
> > > 
> > > I don't see anything here that would prevent grace periods from completing.
> > > 
> > > The CPUs are using the normal hotplug sequence to come online, correct?
> > 
> > And either way, could you please apply the patch below and then
> > invoke rcu_dump_rcu_sched_tree() just before the offending call to
> > synchronize_sched()?  That will tell me what CPUs RCU believes exist,
> > and perhaps also which CPU is holding it up.
> 
> I can't find rcu_dump_rcu_sched_tree(). Do you mean
> rcu_dump_rcu_node_tree()? Anyway, there is no patch below so I attach
> one which does what Paul want, maybe.

One of those days, I guess!  :-/

Your patch is exactly what I intended to send, thank you!

							Thanx, Paul

> Thanks.
> 
> ------->8---------
> diff --git a/kernel/rcu/tree.c b/kernel/rcu/tree.c
> index 88d3f95..6b650f0 100644
> --- a/kernel/rcu/tree.c
> +++ b/kernel/rcu/tree.c
> @@ -4171,7 +4171,7 @@ static void __init rcu_init_geometry(void)
>   * Dump out the structure of the rcu_node combining tree associated
>   * with the rcu_state structure referenced by rsp.
>   */
> -static void __init rcu_dump_rcu_node_tree(struct rcu_state *rsp)
> +static void rcu_dump_rcu_node_tree(struct rcu_state *rsp)
>  {
>         int level = 0;
>         struct rcu_node *rnp;
> @@ -4189,6 +4189,11 @@ static void __init rcu_dump_rcu_node_tree(struct rcu_state *rsp)
>         pr_cont("\n");
>  }
> 
> +void rcu_dump_rcu_sched_tree(void)
> +{
> +       rcu_dump_rcu_node_tree(&rcu_sched_state);
> +}
> +
>  void __init rcu_init(void)
>  {
>         int cpu;
> diff --git a/mm/slab.c b/mm/slab.c
> index 763096a..d88976c 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -909,6 +909,8 @@ static int init_cache_node_node(int node)
>         return 0;
>  }
> 
> +extern void rcu_dump_rcu_sched_tree(void);
> +
>  static int setup_kmem_cache_node(struct kmem_cache *cachep,
>                                 int node, gfp_t gfp, bool force_change)
>  {
> @@ -964,8 +966,10 @@ static int setup_kmem_cache_node(struct kmem_cache *cachep,
>          * guaranteed to be valid until irq is re-enabled, because it will be
>          * freed after synchronize_sched().
>          */
> -       if (force_change)
> +       if (force_change) {
> +               rcu_dump_rcu_sched_tree();
>                 synchronize_sched();
> +       }
> 
>  fail:
>         kfree(old_shared);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
