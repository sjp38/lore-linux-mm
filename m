Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 29FC86B0047
	for <linux-mm@kvack.org>; Sat,  6 Feb 2010 04:48:04 -0500 (EST)
Received: from kpbe11.cbf.corp.google.com (kpbe11.cbf.corp.google.com [172.25.105.75])
	by smtp-out.google.com with ESMTP id o169lxtl032125
	for <linux-mm@kvack.org>; Sat, 6 Feb 2010 01:48:00 -0800
Received: from pzk14 (pzk14.prod.google.com [10.243.19.142])
	by kpbe11.cbf.corp.google.com with ESMTP id o169lvwT027865
	for <linux-mm@kvack.org>; Sat, 6 Feb 2010 03:47:58 -0600
Received: by pzk14 with SMTP id 14so1483721pzk.3
        for <linux-mm@kvack.org>; Sat, 06 Feb 2010 01:47:57 -0800 (PST)
Date: Sat, 6 Feb 2010 01:47:49 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] [2/4] SLAB: Set up the l3 lists for the memory of freshly
 added memory
In-Reply-To: <20100206072636.GO29555@one.firstfloor.org>
Message-ID: <alpine.DEB.2.00.1002060147160.17897@chino.kir.corp.google.com>
References: <201002031039.710275915@firstfloor.org> <20100203213913.D5CD4B1620@basil.firstfloor.org> <alpine.DEB.2.00.1002051316300.2376@chino.kir.corp.google.com> <20100206072636.GO29555@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: submit@firstfloor.org, linux-kernel@vger.kernel.org, haicheng.li@intel.com, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 6 Feb 2010, Andi Kleen wrote:

> > > +static int slab_memory_callback(struct notifier_block *self,
> > > +				unsigned long action, void *arg)
> > > +{
> > > +	struct memory_notify *mn = (struct memory_notify *)arg;
> > 
> > No cast necessary.
> 
> It's standard practice to cast void *.
> 

$ grep -r "struct memory_notify.*=" *
arch/powerpc/platforms/pseries/cmm.c:	struct memory_notify *marg = arg;
drivers/base/node.c:	struct memory_notify *mnb = arg;
drivers/net/ehea/ehea_main.c:	struct memory_notify *arg = data;
mm/ksm.c:	struct memory_notify *mn = arg;
mm/slub.c:	struct memory_notify *marg = arg;
mm/slub.c:	struct memory_notify *marg = arg;
mm/page_cgroup.c:	struct memory_notify *mn = arg;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
