Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 029056B0254
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 13:46:47 -0500 (EST)
Received: by wmvv187 with SMTP id v187so226969521wmv.1
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 10:46:46 -0800 (PST)
Received: from Galois.linutronix.de (linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id b127si32156857wmh.67.2015.12.08.10.46.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 08 Dec 2015 10:46:46 -0800 (PST)
Date: Tue, 8 Dec 2015 19:45:57 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 29/34] x86: separate out LDT init from context init
In-Reply-To: <20151204011504.49720E0D@viggo.jf.intel.com>
Message-ID: <alpine.DEB.2.11.1512081945440.3595@nanos>
References: <20151204011424.8A36E365@viggo.jf.intel.com> <20151204011504.49720E0D@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, dave.hansen@linux.intel.com

On Thu, 3 Dec 2015, Dave Hansen wrote:
> The arch-specific mm_context_t is a great place to put
> protection-key allocation state.
> 
> But, we need to initialize the allocation state because pkey 0 is
> always "allocated".  All of the runtime initialization of
> mm_context_t is done in *_ldt() manipulation functions.  This
> renames the existing LDT functions like this:
> 
> 	init_new_context() -> init_new_context_ldt()
> 	destroy_context() -> destroy_context_ldt()
> 
> and makes init_new_context() and destroy_context() available for
> generic use.

Reviewed-by: Thomas Gleixner <tglx@linutronix.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
