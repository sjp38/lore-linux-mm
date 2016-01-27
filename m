Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id AB3A66B0253
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 04:16:46 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id 123so142291197wmz.0
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 01:16:46 -0800 (PST)
Received: from Galois.linutronix.de (linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id gg9si7271663wjb.115.2016.01.27.01.16.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 27 Jan 2016 01:16:45 -0800 (PST)
Date: Wed, 27 Jan 2016 10:15:35 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v2 1/3] mm: provide debug_pagealloc_enabled() without
 CONFIG_DEBUG_PAGEALLOC
In-Reply-To: <1453884618-33852-2-git-send-email-borntraeger@de.ibm.com>
Message-ID: <alpine.DEB.2.11.1601271015220.3886@nanos>
References: <1453884618-33852-1-git-send-email-borntraeger@de.ibm.com> <1453884618-33852-2-git-send-email-borntraeger@de.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian Borntraeger <borntraeger@de.ibm.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, x86@kernel.org, linuxppc-dev@lists.ozlabs.org, davem@davemloft.net, Joonsoo Kim <iamjoonsoo.kim@lge.com>, davej@codemonkey.org.uk

On Wed, 27 Jan 2016, Christian Borntraeger wrote:

> We can provide debug_pagealloc_enabled() also if CONFIG_DEBUG_PAGEALLOC
> is not set. It will return false in that case.
> 
> Signed-off-by: Christian Borntraeger <borntraeger@de.ibm.com>
> Acked-by: David Rientjes <rientjes@google.com>

Acked-by: Thomas Gleixner <tglx@linutronix.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
