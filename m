Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 977C86B3071
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 04:29:14 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id m19so5533067edc.6
        for <linux-mm@kvack.org>; Fri, 23 Nov 2018 01:29:14 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v9-v6si1972339eje.240.2018.11.23.01.29.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Nov 2018 01:29:13 -0800 (PST)
Date: Fri, 23 Nov 2018 10:29:11 +0100
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH v2 09/17] debugobjects: Make object hash locks nestable
 terminal locks
Message-ID: <20181123092911.vgl2se2jdt3lqi7r@pathway.suse.cz>
References: <1542653726-5655-1-git-send-email-longman@redhat.com>
 <1542653726-5655-10-git-send-email-longman@redhat.com>
 <20181122153302.y5vqovrsaigi6pte@pathway.suse.cz>
 <6879cb32-1d6e-79bd-04c2-8f7c09c48bfe@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6879cb32-1d6e-79bd-04c2-8f7c09c48bfe@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <longman@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Thu 2018-11-22 15:17:52, Waiman Long wrote:
> On 11/22/2018 10:33 AM, Petr Mladek wrote:
> > On Mon 2018-11-19 13:55:18, Waiman Long wrote:
> >> By making the object hash locks nestable terminal locks, we can avoid
> >> a bunch of unnecessary lockdep validations as well as saving space
> >> in the lockdep tables.
> > Please, explain which terminal lock might be nested.
>
> So the db_lock is made to be nestable that it can allow acquisition of
> pool_lock (a regular terminal lock) underneath it.

Please, mention this in the commit message.

Best Regards,
Petr
