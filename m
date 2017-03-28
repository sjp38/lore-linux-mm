Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id A9B2F6B0390
	for <linux-mm@kvack.org>; Tue, 28 Mar 2017 17:35:22 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id z67so226427itb.4
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 14:35:22 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id q4si4546761itc.114.2017.03.28.14.35.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Mar 2017 14:35:21 -0700 (PDT)
Date: Tue, 28 Mar 2017 14:35:13 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 4/8] asm-generic: add atomic-instrumented.h
Message-ID: <20170328213513.GB12803@bombadil.infradead.org>
References: <cover.1490717337.git.dvyukov@google.com>
 <ffaaa56d5099d2926004f0290f73396d0bd842c8.1490717337.git.dvyukov@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ffaaa56d5099d2926004f0290f73396d0bd842c8.1490717337.git.dvyukov@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: mark.rutland@arm.com, peterz@infradead.org, mingo@redhat.com, akpm@linux-foundation.org, will.deacon@arm.com, aryabinin@virtuozzo.com, kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org

On Tue, Mar 28, 2017 at 06:15:41PM +0200, Dmitry Vyukov wrote:
> The new header allows to wrap per-arch atomic operations
> and add common functionality to all of them.

Why a new header instead of putting this in linux/atomic.h?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
