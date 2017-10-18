Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1ECB76B0069
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 10:36:03 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id q18so2209965wmg.18
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 07:36:03 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id u13si10034301wrb.325.2017.10.18.07.36.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 18 Oct 2017 07:36:02 -0700 (PDT)
Date: Wed, 18 Oct 2017 16:35:54 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 1/2] lockdep: Introduce CROSSRELEASE_STACK_TRACE and make
 it not unwind as default
In-Reply-To: <20171018141502.GB12063@bombadil.infradead.org>
Message-ID: <alpine.DEB.2.20.1710181634420.1925@nanos>
References: <1508318006-2090-1-git-send-email-byungchul.park@lge.com> <alpine.DEB.2.20.1710181519580.1925@nanos> <20171018133019.cwfhnt46pvhirt57@gmail.com> <alpine.DEB.2.20.1710181533260.1925@nanos> <20171018141502.GB12063@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Ingo Molnar <mingo@kernel.org>, Byungchul Park <byungchul.park@lge.com>, peterz@infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@lge.com

On Wed, 18 Oct 2017, Matthew Wilcox wrote:

> On Wed, Oct 18, 2017 at 03:36:05PM +0200, Thomas Gleixner wrote:
> > Which reminds me that I wanted to convert them to static_key so they are
> > zero overhead when disabled. Sigh, why are todo lists growth only?
> 
> This is why you need an Outreachy intern -- it gets at least one task
> off your todo list, and in the best possible case, it gets a second
> person working on your todo list for a long time.
> 
> ... eventually they start their own todo lists ...

Good idea. Oh, wait.....  Getting an Outreachy intern is on my todo list already. 

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
