Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f52.google.com (mail-qa0-f52.google.com [209.85.216.52])
	by kanga.kvack.org (Postfix) with ESMTP id EB4B86B0031
	for <linux-mm@kvack.org>; Wed, 29 Jan 2014 10:57:37 -0500 (EST)
Received: by mail-qa0-f52.google.com with SMTP id j15so2633719qaq.39
        for <linux-mm@kvack.org>; Wed, 29 Jan 2014 07:57:37 -0800 (PST)
Received: from qmta12.emeryville.ca.mail.comcast.net (qmta12.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:227])
        by mx.google.com with ESMTP id j4si2011415qao.184.2014.01.29.07.57.37
        for <linux-mm@kvack.org>;
        Wed, 29 Jan 2014 07:57:37 -0800 (PST)
Date: Wed, 29 Jan 2014 09:57:33 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] kthread: ensure locality of task_struct allocations
In-Reply-To: <20140128183808.GB9315@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.10.1401290956060.23856@nuc>
References: <20140128183808.GB9315@linux.vnet.ibm.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Anton Blanchard <anton@samba.org>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Jan Kara <jack@suse.cz>, David Rientjes <rientjes@google.com>, Thomas Gleixner <tglx@linutronix.de>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Ben Herrenschmidt <benh@kernel.crashing.org>

On Tue, 28 Jan 2014, Nishanth Aravamudan wrote:

> In the presence of memoryless nodes, numa_node_id()/cpu_to_node() will
> return the current CPU's NUMA node, but that may not be where we expect
> to allocate from memory from. Instead, we should use
> numa_mem_id()/cpu_to_mem(). On one ppc64 system with a memoryless Node
> 0, this ends up saving nearly 500M of slab due to less fragmentation.

Reviewed-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
