Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 9B2586B0036
	for <linux-mm@kvack.org>; Thu, 30 Jan 2014 17:47:08 -0500 (EST)
Received: by mail-pd0-f174.google.com with SMTP id z10so3595317pdj.33
        for <linux-mm@kvack.org>; Thu, 30 Jan 2014 14:47:08 -0800 (PST)
Received: from mail-pb0-x22b.google.com (mail-pb0-x22b.google.com [2607:f8b0:400e:c01::22b])
        by mx.google.com with ESMTPS id l8si8118554pao.94.2014.01.30.14.47.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 30 Jan 2014 14:47:07 -0800 (PST)
Received: by mail-pb0-f43.google.com with SMTP id md12so3697402pbc.16
        for <linux-mm@kvack.org>; Thu, 30 Jan 2014 14:47:07 -0800 (PST)
Date: Thu, 30 Jan 2014 14:47:05 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] kthread: ensure locality of task_struct allocations
In-Reply-To: <1391062491.28432.68.camel@edumazet-glaptop2.roam.corp.google.com>
Message-ID: <alpine.DEB.2.02.1401301446320.12223@chino.kir.corp.google.com>
References: <20140128183808.GB9315@linux.vnet.ibm.com> <alpine.DEB.2.02.1401290012460.10268@chino.kir.corp.google.com> <alpine.DEB.2.10.1401290957350.23856@nuc> <alpine.DEB.2.02.1401291622550.22974@chino.kir.corp.google.com>
 <1391062491.28432.68.camel@edumazet-glaptop2.roam.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Christoph Lameter <cl@linux.com>, Eric Dumazet <edumazet@google.com>, Nishanth Aravamudan <nacc@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Anton Blanchard <anton@samba.org>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Jan Kara <jack@suse.cz>, Thomas Gleixner <tglx@linutronix.de>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-mm@kvack.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Ben Herrenschmidt <benh@kernel.crashing.org>

On Wed, 29 Jan 2014, Eric Dumazet wrote:

> > Eric, did you try this when writing 207205a2ba26 ("kthread: NUMA aware 
> > kthread_create_on_node()") or was it always numa_node_id() from the 
> > beginning?
> 
> Hmm, I think I did not try this, its absolutely possible NUMA_NO_NODE
> was better here.
> 

Nishanth, could you change your patch to just return NUMA_NO_NODE for the 
non-kthreadd case?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
