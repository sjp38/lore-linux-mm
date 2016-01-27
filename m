Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id DEF666B0256
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 17:18:31 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id yy13so11356781pab.3
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 14:18:31 -0800 (PST)
Received: from mail-pa0-x236.google.com (mail-pa0-x236.google.com. [2607:f8b0:400e:c03::236])
        by mx.google.com with ESMTPS id ca7si11979053pad.240.2016.01.27.14.18.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jan 2016 14:18:31 -0800 (PST)
Received: by mail-pa0-x236.google.com with SMTP id ho8so11414599pac.2
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 14:18:31 -0800 (PST)
Date: Wed, 27 Jan 2016 14:18:29 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v3 3/3] s390: query dynamic DEBUG_PAGEALLOC setting
In-Reply-To: <1453889401-43496-4-git-send-email-borntraeger@de.ibm.com>
Message-ID: <alpine.DEB.2.10.1601271418190.23510@chino.kir.corp.google.com>
References: <1453889401-43496-1-git-send-email-borntraeger@de.ibm.com> <1453889401-43496-4-git-send-email-borntraeger@de.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian Borntraeger <borntraeger@de.ibm.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, x86@kernel.org, linuxppc-dev@lists.ozlabs.org, davem@davemloft.net, Joonsoo Kim <iamjoonsoo.kim@lge.com>, davej@codemonkey.org.uk

On Wed, 27 Jan 2016, Christian Borntraeger wrote:

> We can use debug_pagealloc_enabled() to check if we can map
> the identity mapping with 1MB/2GB pages as well as to print
> the current setting in dump_stack.
> 
> Signed-off-by: Christian Borntraeger <borntraeger@de.ibm.com>
> Reviewed-by: Heiko Carstens <heiko.carstens@de.ibm.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
