Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8E1C66B02C3
	for <linux-mm@kvack.org>; Tue,  4 Jul 2017 11:32:42 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id p204so24643853wmg.3
        for <linux-mm@kvack.org>; Tue, 04 Jul 2017 08:32:42 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id w201si9688826wme.103.2017.07.04.08.32.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 04 Jul 2017 08:32:41 -0700 (PDT)
Date: Tue, 4 Jul 2017 17:32:37 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [patch V2 2/2] mm/memory-hotplug: Switch locking to a percpu
 rwsem
In-Reply-To: <20170704152206.GB11168@linux-80c1.suse>
Message-ID: <alpine.DEB.2.20.1707041732030.9000@nanos>
References: <20170704093232.995040438@linutronix.de> <20170704093421.506836322@linutronix.de> <20170704150106.GA11168@linux-80c1.suse> <20170704152206.GB11168@linux-80c1.suse>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <dave@stgolabs.net>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrey Ryabinin <aryabinin@virtuozzo.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Vladimir Davydov <vdavydov.dev@gmail.com>, Peter Zijlstra <peterz@infradead.org>

On Tue, 4 Jul 2017, Davidlohr Bueso wrote:
> On Tue, 04 Jul 2017, Davidlohr Bueso wrote:
> 
> > As a side effect you end up optimizing get/put_online_mems() at the cost
> > of more overhead for the actual hotplug operation, which is rare and of less
> > performance importance.
> 
> So nm this, the reader side actually gets _more_ expensive with pcpu-rwsems
> due to at least two full barriers for each get/put operation.

Compared to a mutex_lock/unlock() pair on a global mutex ....

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
