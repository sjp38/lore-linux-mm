Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 214286B0033
	for <linux-mm@kvack.org>; Sat,  4 Nov 2017 09:47:14 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id v78so5684809pfk.8
        for <linux-mm@kvack.org>; Sat, 04 Nov 2017 06:47:14 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id m16si8322692pgv.244.2017.11.04.06.47.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 04 Nov 2017 06:47:12 -0700 (PDT)
Date: Sat, 4 Nov 2017 06:47:09 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm: filemap: remove include of hardirq.h
Message-ID: <20171104134709.GA23784@bombadil.infradead.org>
References: <1509734868-120762-1-git-send-email-yang.s@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1509734868-120762-1-git-send-email-yang.s@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.s@alibaba-inc.com>
Cc: mhocko@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, Nov 04, 2017 at 02:47:48AM +0800, Yang Shi wrote:
> in_atomic() has been moved to include/linux/preempt.h, and the filemap.c
> doesn't use in_atomic() directly at all, so it sounds unnecessary to
> include hardirq.h.
> With removing hardirq.h, around 32 bytes can be saved for x86_64 bzImage
> with allnoconfig.

Wait, what?  How would including an unused header file increase the size
of the final image?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
