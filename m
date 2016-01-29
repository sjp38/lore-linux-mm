Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 71B3E6B0009
	for <linux-mm@kvack.org>; Fri, 29 Jan 2016 09:00:31 -0500 (EST)
Received: by mail-wm0-f42.google.com with SMTP id l66so55728817wml.0
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 06:00:31 -0800 (PST)
Received: from Galois.linutronix.de (linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id bj10si22343288wjc.110.2016.01.29.06.00.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 29 Jan 2016 06:00:30 -0800 (PST)
Date: Fri, 29 Jan 2016 14:59:23 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 1/1] x86: also use debug_pagealloc_enabled() for
 free_init_pages
In-Reply-To: <1454071934-24291-2-git-send-email-borntraeger@de.ibm.com>
Message-ID: <alpine.DEB.2.11.1601291459120.3886@nanos>
References: <1454071934-24291-1-git-send-email-borntraeger@de.ibm.com> <1454071934-24291-2-git-send-email-borntraeger@de.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian Borntraeger <borntraeger@de.ibm.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, davej@codemonkey.org.uk, David Rientjes <rientjes@google.com>

On Fri, 29 Jan 2016, Christian Borntraeger wrote:

> we want to couple all debugging features with debug_pagealloc_enabled()
> and not with the config option CONFIG_DEBUG_PAGEALLOC.
> 
> Suggested-by: David Rientjes <rientjes@google.com>
> Signed-off-by: Christian Borntraeger <borntraeger@de.ibm.com>

Reviewed-by: Thomas Gleixner <tglx@linutronix.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
