Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5C4F1680FBC
	for <linux-mm@kvack.org>; Wed,  5 Jul 2017 17:53:38 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id v88so462874wrb.1
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 14:53:38 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id i88si19112739wmh.177.2017.07.05.14.53.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jul 2017 14:53:37 -0700 (PDT)
Date: Wed, 5 Jul 2017 14:53:34 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch V2 0/2] mm/memory_hotplug: Cure potential deadlocks vs.
 cpu hotplug lock
Message-Id: <20170705145334.d73a30dda944855349e522ed@linux-foundation.org>
In-Reply-To: <20170704093232.995040438@linutronix.de>
References: <20170704093232.995040438@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrey Ryabinin <aryabinin@virtuozzo.com>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Vladimir Davydov <vdavydov.dev@gmail.com>, Peter Zijlstra <peterz@infradead.org>

On Tue, 04 Jul 2017 11:32:32 +0200 Thomas Gleixner <tglx@linutronix.de> wrote:

> Andrey reported a potential deadlock with the memory hotplug lock and the
> cpu hotplug lock.
> 
> The following series addresses this by reworking the memory hotplug locking
> and fixing up the potential deadlock scenarios.

Do you think we should squeeze this into 4.13-rc1, or can we afford to
take the more cautious route?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
