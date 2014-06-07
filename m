Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f175.google.com (mail-ie0-f175.google.com [209.85.223.175])
	by kanga.kvack.org (Postfix) with ESMTP id 30CFB6B0031
	for <linux-mm@kvack.org>; Sat,  7 Jun 2014 17:50:33 -0400 (EDT)
Received: by mail-ie0-f175.google.com with SMTP id tp5so2194464ieb.20
        for <linux-mm@kvack.org>; Sat, 07 Jun 2014 14:50:33 -0700 (PDT)
Received: from mail-ie0-x235.google.com (mail-ie0-x235.google.com [2607:f8b0:4001:c03::235])
        by mx.google.com with ESMTPS id nu10si15669173igb.1.2014.06.07.14.50.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 07 Jun 2014 14:50:32 -0700 (PDT)
Received: by mail-ie0-f181.google.com with SMTP id y20so261341ier.12
        for <linux-mm@kvack.org>; Sat, 07 Jun 2014 14:50:32 -0700 (PDT)
Date: Sat, 7 Jun 2014 14:50:30 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2] mm: rmap: fix use-after-free in __put_anon_vma
In-Reply-To: <1402067370-5773-1-git-send-email-a.ryabinin@samsung.com>
Message-ID: <alpine.DEB.2.02.1406071450190.24927@chino.kir.corp.google.com>
References: <20140606115620.GS3213@twins.programming.kicks-ass.net> <1402067370-5773-1-git-send-email-a.ryabinin@samsung.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, koct9i@gmail.com, stable@vger.kernel.org

On Fri, 6 Jun 2014, Andrey Ryabinin wrote:

> While working address sanitizer for kernel I've discovered use-after-free
> bug in __put_anon_vma.
> For the last anon_vma, anon_vma->root freed before child anon_vma.
> Later in anon_vma_free(anon_vma) we are referencing to already freed anon_vma->root
> to check rwsem.
> This patch puts freeing of child anon_vma before freeing of anon_vma->root.
> 
> Cc: <stable@vger.kernel.org> # v3.0+
> Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
