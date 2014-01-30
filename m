Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 6821E6B0035
	for <linux-mm@kvack.org>; Thu, 30 Jan 2014 18:31:50 -0500 (EST)
Received: by mail-pd0-f182.google.com with SMTP id v10so3644038pde.27
        for <linux-mm@kvack.org>; Thu, 30 Jan 2014 15:31:50 -0800 (PST)
Received: from mail-pd0-x22e.google.com (mail-pd0-x22e.google.com [2607:f8b0:400e:c02::22e])
        by mx.google.com with ESMTPS id l8si8212646pao.152.2014.01.30.15.31.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 30 Jan 2014 15:31:49 -0800 (PST)
Received: by mail-pd0-f174.google.com with SMTP id z10so3635903pdj.33
        for <linux-mm@kvack.org>; Thu, 30 Jan 2014 15:31:49 -0800 (PST)
Date: Thu, 30 Jan 2014 15:31:45 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] kthread: ensure locality of task_struct allocations
In-Reply-To: <20140130230812.GA874@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.02.1401301531280.16167@chino.kir.corp.google.com>
References: <20140128183808.GB9315@linux.vnet.ibm.com> <alpine.DEB.2.02.1401290012460.10268@chino.kir.corp.google.com> <alpine.DEB.2.10.1401290957350.23856@nuc> <alpine.DEB.2.02.1401291622550.22974@chino.kir.corp.google.com>
 <1391062491.28432.68.camel@edumazet-glaptop2.roam.corp.google.com> <alpine.DEB.2.02.1401301446320.12223@chino.kir.corp.google.com> <20140130230812.GA874@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Christoph Lameter <cl@linux.com>, Eric Dumazet <edumazet@google.com>, LKML <linux-kernel@vger.kernel.org>, Anton Blanchard <anton@samba.org>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Jan Kara <jack@suse.cz>, Thomas Gleixner <tglx@linutronix.de>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-mm@kvack.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Ben Herrenschmidt <benh@kernel.crashing.org>

On Thu, 30 Jan 2014, Nishanth Aravamudan wrote:

> In the presence of memoryless nodes, numa_node_id() will return the
> current CPU's NUMA node, but that may not be where we expect to allocate
> from memory from. Instead, we should rely on the fallback code in the
> memory allocator itself, by using NUMA_NO_NODE. Also, when calling
> kthread_create_on_node(), use the nearest node with memory to the cpu in
> question, rather than the node it is running on.
> 
> Signed-off-by: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
