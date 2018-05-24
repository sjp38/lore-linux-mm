Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id CCC6E6B0005
	for <linux-mm@kvack.org>; Thu, 24 May 2018 03:14:21 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id r4-v6so311108pgq.2
        for <linux-mm@kvack.org>; Thu, 24 May 2018 00:14:21 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id e2-v6si16683475pga.647.2018.05.24.00.14.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 24 May 2018 00:14:19 -0700 (PDT)
Date: Thu, 24 May 2018 09:14:13 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 3/8] md: raid5: use refcount_t for reference counting
 instead atomic_t
Message-ID: <20180524071413.GC12198@hirez.programming.kicks-ass.net>
References: <20180509193645.830-1-bigeasy@linutronix.de>
 <20180509193645.830-4-bigeasy@linutronix.de>
 <20180523132119.GC19987@bombadil.infradead.org>
 <20180523174904.GY12198@hirez.programming.kicks-ass.net>
 <20180523192239.GA59657@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180523192239.GA59657@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: Matthew Wilcox <willy@infradead.org>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, linux-kernel@vger.kernel.org, tglx@linutronix.de, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org, linux-raid@vger.kernel.org, Anna-Maria Gleixner <anna-maria@linutronix.de>

On Wed, May 23, 2018 at 12:22:39PM -0700, Shaohua Li wrote:
> I don't know what is changed in the refcount, such raid5 change has attempted
> before and didn't work. 0 for the stripe count is a valid usage and we do
> inc-from-zero in several places.

Nothing much has changed with refcount; and the above does indeed still
appear to be an issue. Thanks for confirming.
