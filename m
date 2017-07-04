Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id E0A716B02C3
	for <linux-mm@kvack.org>; Tue,  4 Jul 2017 11:22:17 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id b20so24602007wmd.6
        for <linux-mm@kvack.org>; Tue, 04 Jul 2017 08:22:17 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j79si5639400wmf.14.2017.07.04.08.22.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 04 Jul 2017 08:22:16 -0700 (PDT)
Date: Tue, 4 Jul 2017 08:22:06 -0700
From: Davidlohr Bueso <dave@stgolabs.net>
Subject: Re: [patch V2 2/2] mm/memory-hotplug: Switch locking to a percpu
 rwsem
Message-ID: <20170704152206.GB11168@linux-80c1.suse>
References: <20170704093232.995040438@linutronix.de>
 <20170704093421.506836322@linutronix.de>
 <20170704150106.GA11168@linux-80c1.suse>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20170704150106.GA11168@linux-80c1.suse>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrey Ryabinin <aryabinin@virtuozzo.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Vladimir Davydov <vdavydov.dev@gmail.com>, Peter Zijlstra <peterz@infradead.org>

On Tue, 04 Jul 2017, Davidlohr Bueso wrote:

>As a side effect you end up optimizing get/put_online_mems() at the cost
>of more overhead for the actual hotplug operation, which is rare and of less
>performance importance.

So nm this, the reader side actually gets _more_ expensive with pcpu-rwsems
due to at least two full barriers for each get/put operation.

Thanks,
Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
