Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 61E226B02E7
	for <linux-mm@kvack.org>; Tue,  8 May 2018 19:03:00 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id h32-v6so2612222pld.15
        for <linux-mm@kvack.org>; Tue, 08 May 2018 16:03:00 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id c10-v6si7280455pgq.79.2018.05.08.16.02.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 May 2018 16:02:59 -0700 (PDT)
Date: Tue, 8 May 2018 16:02:57 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH REPOST] Revert mm/vmstat.c: fix vmstat_update()
 preemption BUG
Message-Id: <20180508160257.6e19707ccf1dabe5ec9e8847@linux-foundation.org>
In-Reply-To: <513014a0-a149-5141-a5a0-9b0a4ce9a8d8@suse.cz>
References: <20180504104451.20278-1-bigeasy@linutronix.de>
	<513014a0-a149-5141-a5a0-9b0a4ce9a8d8@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Sebastian Andrzej Siewior <bigeasy@linutronix.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tglx@linutronix.de, "Steven J . Hill" <steven.hill@cavium.com>, Tejun Heo <htejun@gmail.com>, Christoph Lameter <cl@linux.com>

On Mon, 7 May 2018 09:31:05 +0200 Vlastimil Babka <vbabka@suse.cz> wrote:

> In any case I agree that the revert should be done immediately even
> before fixing the underlying bug. The preempt_disable/enable doesn't
> prevent the bug, it only prevents the debugging code from actually
> reporting it! Note that it's debugging code (CONFIG_DEBUG_PREEMPT) that
> production kernels most likely don't have enabled, so we are not even
> helping them not crash (while allowing possible data corruption).

Grumble.

I don't see much benefit in emitting warnings into end-users' logs for
bugs which we already know about.

The only thing this buys us is that people will hassle us if we forget
to fix the bug, and how pathetic is that?  I mean, we may as well put

	printk("don't forget to fix the vmstat_update() bug!\n");

into start_kernel().
