Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 091946B02C4
	for <linux-mm@kvack.org>; Tue, 16 May 2017 10:19:01 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id 206so100881951iob.2
        for <linux-mm@kvack.org>; Tue, 16 May 2017 07:19:01 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id f139si3139956itb.75.2017.05.16.07.18.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 May 2017 07:19:00 -0700 (PDT)
Date: Tue, 16 May 2017 16:18:46 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v6 05/15] lockdep: Implement crossrelease feature
Message-ID: <20170516141846.GM4626@worktop.programming.kicks-ass.net>
References: <1489479542-27030-1-git-send-email-byungchul.park@lge.com>
 <1489479542-27030-6-git-send-email-byungchul.park@lge.com>
 <20170419142503.rqsrgjlc7ump7ijb@hirez.programming.kicks-ass.net>
 <20170424051102.GJ21430@X58A-UD3R>
 <20170424101747.iirvjjoq66x25w7n@hirez.programming.kicks-ass.net>
 <20170425054044.GK21430@X58A-UD3R>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170425054044.GK21430@X58A-UD3R>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com

On Tue, Apr 25, 2017 at 02:40:44PM +0900, Byungchul Park wrote:
> On Mon, Apr 24, 2017 at 12:17:47PM +0200, Peter Zijlstra wrote:

> > My complaint is mostly about naming.. and "hist_gen_id" might be a
> > better name.
> 
> Ah, I also think the name, 'work_id', is not good... and frankly I am
> not sure if 'hist_gen_id' is good, either. What about to apply 'rollback',
> which I did for locks in irq, into works of workqueues? If you say yes,
> I will try to do it.

If the rollback thing works, that's fine too. If it gets ugly, stick
with something like 'hist_id'.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
