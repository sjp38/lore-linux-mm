Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id EDFAA6B0033
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 09:50:55 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id h12so1437065wre.12
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 06:50:55 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id s4si1508519wrf.380.2017.12.13.06.50.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 13 Dec 2017 06:50:54 -0800 (PST)
Date: Wed, 13 Dec 2017 15:50:44 +0100
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: [PATCH RT] mm/slub: close possible memory-leak in
 kmem_cache_alloc_bulk()
Message-ID: <20171213145044.falrw5jsskq2ocha@linutronix.de>
References: <20171213140555.s4hzg3igtjfgaueh@linutronix.de>
 <20171213154654.2971ef2a@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20171213154654.2971ef2a@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: linux-rt-users@vger.kernel.org, linux-kernel@vger.kernel.org, tglx@linutronix.de, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, linux-mm@kvack.org, Rao Shoaib <rao.shoaib@oracle.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On 2017-12-13 15:46:54 [+0100], Jesper Dangaard Brouer wrote:
> > Jesper: There are no users of kmem_cache_alloc_bulk() and kfree_bulk().
> > Only kmem_cache_free_bulk() is used since it was introduced. Do you
> > think that it would make sense to remove those?
> 
> I would like to keep them.
> 
> Rao Shoaib (Cc'ed) is/was working on a patchset for RCU-bulk-free that
> used the kfree_bulk() API.
> 
> I plan to use kmem_cache_alloc_bulk() in the bpf-map "cpumap", for bulk
> allocating SKBs during dequeue of XDP frames.  (My original bulk alloc
> SKBs use-case during NAPI/softirq was never merged).

I see. So it may gain users in future you say.

> I've not seen free_delayed() before... and my cscope cannot find it...
It is PREEMPT RT only, mainline is not affected (that is why there is a
RT next to the PATCH in subject).

Sebastian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
