Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id A9DD26B0035
	for <linux-mm@kvack.org>; Fri, 18 Jul 2014 08:40:45 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id et14so5415256pad.9
        for <linux-mm@kvack.org>; Fri, 18 Jul 2014 05:40:45 -0700 (PDT)
Received: from mho-02-ewr.mailhop.org (mho-02-ewr.mailhop.org. [204.13.248.72])
        by mx.google.com with ESMTPS id n107si10283533qgn.45.2014.07.18.05.40.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 18 Jul 2014 05:40:44 -0700 (PDT)
Date: Fri, 18 Jul 2014 08:40:38 -0400
From: Jason Cooper <jason@lakedaemon.net>
Subject: Re: [RFC Patch V1 21/30] mm, irqchip: Use
 cpu_to_mem()/numa_mem_id() to support memoryless node
Message-ID: <20140718124038.GE24496@titan.lakedaemon.net>
References: <1405064267-11678-1-git-send-email-jiang.liu@linux.intel.com>
 <1405064267-11678-22-git-send-email-jiang.liu@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1405064267-11678-22-git-send-email-jiang.liu@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <jiang.liu@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Mike Galbraith <umgwanakikbuti@gmail.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Alexander Shiyan <shc_work@mail.ru>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org

On Fri, Jul 11, 2014 at 03:37:38PM +0800, Jiang Liu wrote:
> When CONFIG_HAVE_MEMORYLESS_NODES is enabled, cpu_to_node()/numa_node_id()
> may return a node without memory, and later cause system failure/panic
> when calling kmalloc_node() and friends with returned node id.
> So use cpu_to_mem()/numa_mem_id() instead to get the nearest node with
> memory for the/current cpu.
> 
> If CONFIG_HAVE_MEMORYLESS_NODES is disabled, cpu_to_mem()/numa_mem_id()
> is the same as cpu_to_node()/numa_node_id().
> 
> Signed-off-by: Jiang Liu <jiang.liu@linux.intel.com>
> ---
>  drivers/irqchip/irq-clps711x.c |    2 +-
>  drivers/irqchip/irq-gic.c      |    2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)

Do you have anything depending on this?  Can apply it to irqchip?  If
you need to keep it with other changes,

Acked-by: Jason Cooper <jason@lakedaemon.net>

But please do let me know if I can take it.

thx,

Jason.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
