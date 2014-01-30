Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 8E19C6B0037
	for <linux-mm@kvack.org>; Thu, 30 Jan 2014 01:14:55 -0500 (EST)
Received: by mail-pd0-f170.google.com with SMTP id p10so2658919pdj.29
        for <linux-mm@kvack.org>; Wed, 29 Jan 2014 22:14:55 -0800 (PST)
Received: from mail-pb0-x235.google.com (mail-pb0-x235.google.com [2607:f8b0:400e:c01::235])
        by mx.google.com with ESMTPS id l8si5125717pao.152.2014.01.29.22.14.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 29 Jan 2014 22:14:54 -0800 (PST)
Received: by mail-pb0-f53.google.com with SMTP id md12so2729217pbc.40
        for <linux-mm@kvack.org>; Wed, 29 Jan 2014 22:14:54 -0800 (PST)
Message-ID: <1391062491.28432.68.camel@edumazet-glaptop2.roam.corp.google.com>
Subject: Re: [PATCH] kthread: ensure locality of task_struct allocations
From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 29 Jan 2014 22:14:51 -0800
In-Reply-To: <alpine.DEB.2.02.1401291622550.22974@chino.kir.corp.google.com>
References: <20140128183808.GB9315@linux.vnet.ibm.com>
	 <alpine.DEB.2.02.1401290012460.10268@chino.kir.corp.google.com>
	 <alpine.DEB.2.10.1401290957350.23856@nuc>
	 <alpine.DEB.2.02.1401291622550.22974@chino.kir.corp.google.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Christoph Lameter <cl@linux.com>, Eric Dumazet <edumazet@google.com>, Nishanth Aravamudan <nacc@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Anton Blanchard <anton@samba.org>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Jan Kara <jack@suse.cz>, Thomas Gleixner <tglx@linutronix.de>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-mm@kvack.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Ben Herrenschmidt <benh@kernel.crashing.org>

On Wed, 2014-01-29 at 16:27 -0800, David Rientjes wrote:

> Eric, did you try this when writing 207205a2ba26 ("kthread: NUMA aware 
> kthread_create_on_node()") or was it always numa_node_id() from the 
> beginning?

Hmm, I think I did not try this, its absolutely possible NUMA_NO_NODE
was better here.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
