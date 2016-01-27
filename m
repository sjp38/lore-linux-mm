Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 054A26B0255
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 04:17:06 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id n5so17917387wmn.1
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 01:17:05 -0800 (PST)
Received: from Galois.linutronix.de (linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id hp6si3299118wjb.162.2016.01.27.01.17.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 27 Jan 2016 01:17:05 -0800 (PST)
Date: Wed, 27 Jan 2016 10:16:01 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v2 2/3] x86: query dynamic DEBUG_PAGEALLOC setting
In-Reply-To: <1453884618-33852-3-git-send-email-borntraeger@de.ibm.com>
Message-ID: <alpine.DEB.2.11.1601271015380.3886@nanos>
References: <1453884618-33852-1-git-send-email-borntraeger@de.ibm.com> <1453884618-33852-3-git-send-email-borntraeger@de.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian Borntraeger <borntraeger@de.ibm.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, x86@kernel.org, linuxppc-dev@lists.ozlabs.org, davem@davemloft.net, Joonsoo Kim <iamjoonsoo.kim@lge.com>, davej@codemonkey.org.uk

On Wed, 27 Jan 2016, Christian Borntraeger wrote:

> We can use debug_pagealloc_enabled() to check if we can map
> the identity mapping with 2MB pages. We can also add the state
> into the dump_stack output.
> 
> The patch does not touch the code for the 1GB pages, which ignored
> CONFIG_DEBUG_PAGEALLOC. Do we need to fence this as well?
> 
> Signed-off-by: Christian Borntraeger <borntraeger@de.ibm.com>

Reviewed-by: Thomas Gleixner <tglx@linutronix.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
