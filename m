Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f172.google.com (mail-we0-f172.google.com [74.125.82.172])
	by kanga.kvack.org (Postfix) with ESMTP id 8AD4C6B0035
	for <linux-mm@kvack.org>; Sat, 12 Jul 2014 08:32:05 -0400 (EDT)
Received: by mail-we0-f172.google.com with SMTP id x48so428943wes.3
        for <linux-mm@kvack.org>; Sat, 12 Jul 2014 05:32:04 -0700 (PDT)
Received: from mail-we0-f179.google.com (mail-we0-f179.google.com [74.125.82.179])
        by mx.google.com with ESMTPS id cy7si9063723wjb.50.2014.07.12.05.32.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 12 Jul 2014 05:32:04 -0700 (PDT)
Received: by mail-we0-f179.google.com with SMTP id u57so6130wes.24
        for <linux-mm@kvack.org>; Sat, 12 Jul 2014 05:32:04 -0700 (PDT)
Message-ID: <53C12AC1.4010002@kernel.dk>
Date: Sat, 12 Jul 2014 14:32:01 +0200
From: Jens Axboe <axboe@kernel.dk>
MIME-Version: 1.0
Subject: Re: [RFC Patch V1 01/30] mm, kernel: Use cpu_to_mem()/numa_mem_id()
 to support memoryless node
References: <1405064267-11678-1-git-send-email-jiang.liu@linux.intel.com> <1405064267-11678-2-git-send-email-jiang.liu@linux.intel.com>
In-Reply-To: <1405064267-11678-2-git-send-email-jiang.liu@linux.intel.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <jiang.liu@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Mike Galbraith <umgwanakikbuti@gmail.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Dipankar Sarma <dipankar@in.ibm.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Balbir Singh <bsingharora@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Frederic Weisbecker <fweisbec@gmail.com>, Jan Kara <jack@suse.cz>, Ingo Molnar <mingo@kernel.org>, Christoph Hellwig <hch@infradead.org>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Roman Gushchin <klamm@yandex-team.ru>, Xie XiuQi <xiexiuqi@huawei.com>
Cc: Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org

On 2014-07-11 09:37, Jiang Liu wrote:
> When CONFIG_HAVE_MEMORYLESS_NODES is enabled, cpu_to_node()/numa_node_id()
> may return a node without memory, and later cause system failure/panic
> when calling kmalloc_node() and friends with returned node id.
> So use cpu_to_mem()/numa_mem_id() instead to get the nearest node with
> memory for the/current cpu.
>
> If CONFIG_HAVE_MEMORYLESS_NODES is disabled, cpu_to_mem()/numa_mem_id()
> is the same as cpu_to_node()/numa_node_id().

I think blk-mq requires some of the same help, as do other places in the 
block layer. I'll take a look at that.

As for you smp.c bits here:

Acked-by: Jens Axboe <axboe@fb.com>

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
