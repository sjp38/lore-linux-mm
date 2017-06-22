Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id CD14383292
	for <linux-mm@kvack.org>; Thu, 22 Jun 2017 17:14:15 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id z45so7740297wrb.13
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 14:14:15 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id a135si2271762wmd.2.2017.06.22.14.14.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Jun 2017 14:14:14 -0700 (PDT)
Date: Thu, 22 Jun 2017 14:14:11 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v5 1/4] x86: switch atomic.h to use
 atomic-instrumented.h
Message-Id: <20170622141411.6af8091132e4416e3635b62e@linux-foundation.org>
In-Reply-To: <ff85407a7476ac41bfbdd46a35a93b8f57fa4b1e.1498140838.git.dvyukov@google.com>
References: <cover.1498140468.git.dvyukov@google.com>
	<ff85407a7476ac41bfbdd46a35a93b8f57fa4b1e.1498140838.git.dvyukov@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: mark.rutland@arm.com, peterz@infradead.org, mingo@redhat.com, will.deacon@arm.com, hpa@zytor.com, aryabinin@virtuozzo.com, kasan-dev@googlegroups.com, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 22 Jun 2017 16:14:16 +0200 Dmitry Vyukov <dvyukov@google.com> wrote:

> Add arch_ prefix to all atomic operations and include
> <asm-generic/atomic-instrumented.h>. This will allow
> to add KASAN instrumentation to all atomic ops.

This gets a large number of (simple) rejects when applied to
linux-next.  Can you please redo against -next?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
