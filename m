Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 791276B03E0
	for <linux-mm@kvack.org>; Thu,  6 Jul 2017 02:34:08 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id 4so2388001wrc.15
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 23:34:08 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id a13si7012961wma.62.2017.07.05.23.34.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 05 Jul 2017 23:34:07 -0700 (PDT)
Date: Thu, 6 Jul 2017 08:34:00 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [patch V2 0/2] mm/memory_hotplug: Cure potential deadlocks vs.
 cpu hotplug lock
In-Reply-To: <20170705145334.d73a30dda944855349e522ed@linux-foundation.org>
Message-ID: <alpine.DEB.2.20.1707060833130.1771@nanos>
References: <20170704093232.995040438@linutronix.de> <20170705145334.d73a30dda944855349e522ed@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrey Ryabinin <aryabinin@virtuozzo.com>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Vladimir Davydov <vdavydov.dev@gmail.com>, Peter Zijlstra <peterz@infradead.org>

On Wed, 5 Jul 2017, Andrew Morton wrote:
> On Tue, 04 Jul 2017 11:32:32 +0200 Thomas Gleixner <tglx@linutronix.de> wrote:
> 
> > Andrey reported a potential deadlock with the memory hotplug lock and the
> > cpu hotplug lock.
> > 
> > The following series addresses this by reworking the memory hotplug locking
> > and fixing up the potential deadlock scenarios.
> 
> Do you think we should squeeze this into 4.13-rc1, or can we afford to
> take the more cautious route?

The deadlocks are real and the lockdep splats are triggering on Linus head,
so it should go into 4.13-rc1 if possible.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
