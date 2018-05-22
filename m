Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 04CC56B0003
	for <linux-mm@kvack.org>; Tue, 22 May 2018 17:03:14 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e3-v6so11875776pfe.15
        for <linux-mm@kvack.org>; Tue, 22 May 2018 14:03:13 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id n13-v6si13190230pgd.541.2018.05.22.14.03.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 May 2018 14:03:07 -0700 (PDT)
Date: Tue, 22 May 2018 14:03:05 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/kasan: Don't vfree() nonexistent vm_area.
Message-Id: <20180522140305.5e0f8c62dcc2d735ed4ee84c@linux-foundation.org>
In-Reply-To: <4fc394ae-65e8-7c51-112a-81bee0fb8429@virtuozzo.com>
References: <12c9e499-9c11-d248-6a3f-14ec8c4e07f1@molgen.mpg.de>
	<20180201163349.8700-1-aryabinin@virtuozzo.com>
	<4fc394ae-65e8-7c51-112a-81bee0fb8429@virtuozzo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Paul Menzel <pmenzel+linux-kasan-dev@molgen.mpg.de>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@vger.kernel.org

On Tue, 22 May 2018 19:44:06 +0300 Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:

> > Obviously we can't call vfree() to free memory that wasn't allocated via
> > vmalloc(). Use find_vm_area() to see if we can call vfree().
> > 
> > Unfortunately it's a bit tricky to properly unmap and free shadow allocated
> > during boot, so we'll have to keep it. If memory will come online again
> > that shadow will be reused.
> > 
> > Fixes: fa69b5989bb0 ("mm/kasan: add support for memory hotplug")
> > Reported-by: Paul Menzel <pmenzel+linux-kasan-dev@molgen.mpg.de>
> > Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> > Cc: <stable@vger.kernel.org>
> > ---
> 
> This seems stuck in -mm. Andrew, can we proceed?

OK.

Should there be a code comment explaining the situation that Matthew
asked about?  It's rather obscure.
