Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id DE8C06B0005
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 05:44:23 -0500 (EST)
Received: by mail-wm0-f42.google.com with SMTP id l66so63711303wml.0
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 02:44:23 -0800 (PST)
Received: from Galois.linutronix.de (linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id le8si9104846wjb.80.2016.02.03.02.44.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 03 Feb 2016 02:44:23 -0800 (PST)
Date: Wed, 3 Feb 2016 11:43:14 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v4 4/4] x86: also use debug_pagealloc_enabled() for
 free_init_pages
In-Reply-To: <1454488775-108777-5-git-send-email-borntraeger@de.ibm.com>
Message-ID: <alpine.DEB.2.11.1602031142320.25254@nanos>
References: <1454488775-108777-1-git-send-email-borntraeger@de.ibm.com> <1454488775-108777-5-git-send-email-borntraeger@de.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian Borntraeger <borntraeger@de.ibm.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, David Rientjes <rientjes@google.com>

On Wed, 3 Feb 2016, Christian Borntraeger wrote:

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
