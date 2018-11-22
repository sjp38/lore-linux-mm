Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 00EFD6B2BEB
	for <linux-mm@kvack.org>; Thu, 22 Nov 2018 10:33:07 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id c18so4532312edt.23
        for <linux-mm@kvack.org>; Thu, 22 Nov 2018 07:33:06 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q24-v6si10925143ejb.146.2018.11.22.07.33.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Nov 2018 07:33:05 -0800 (PST)
Date: Thu, 22 Nov 2018 16:33:02 +0100
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH v2 09/17] debugobjects: Make object hash locks nestable
 terminal locks
Message-ID: <20181122153302.y5vqovrsaigi6pte@pathway.suse.cz>
References: <1542653726-5655-1-git-send-email-longman@redhat.com>
 <1542653726-5655-10-git-send-email-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1542653726-5655-10-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <longman@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Mon 2018-11-19 13:55:18, Waiman Long wrote:
> By making the object hash locks nestable terminal locks, we can avoid
> a bunch of unnecessary lockdep validations as well as saving space
> in the lockdep tables.

Please, explain which terminal lock might be nested.

Hmm, it would hide eventual nesting of other terminal locks.
It might reduce lockdep reliability. I wonder if the space
optimization is worth it.

Finally, it might be good to add a short explanation what (nested)
terminal locks mean into each commit. It would help people to
understand the effect without digging into the lockdep code, ...

Best Regards,
Petr
