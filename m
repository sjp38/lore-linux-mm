Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f180.google.com (mail-pf0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 8509F82963
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 17:48:45 -0500 (EST)
Received: by mail-pf0-f180.google.com with SMTP id 65so21444035pfd.2
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 14:48:45 -0800 (PST)
Received: from mail-pf0-x22d.google.com (mail-pf0-x22d.google.com. [2607:f8b0:400e:c00::22d])
        by mx.google.com with ESMTPS id h89si11933437pfh.148.2016.02.03.14.48.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Feb 2016 14:48:45 -0800 (PST)
Received: by mail-pf0-x22d.google.com with SMTP id 65so21443868pfd.2
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 14:48:44 -0800 (PST)
Date: Wed, 3 Feb 2016 14:48:43 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v4 3/4] s390: query dynamic DEBUG_PAGEALLOC setting
In-Reply-To: <1454488775-108777-4-git-send-email-borntraeger@de.ibm.com>
Message-ID: <alpine.DEB.2.10.1602031448290.10331@chino.kir.corp.google.com>
References: <1454488775-108777-1-git-send-email-borntraeger@de.ibm.com> <1454488775-108777-4-git-send-email-borntraeger@de.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian Borntraeger <borntraeger@de.ibm.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>

On Wed, 3 Feb 2016, Christian Borntraeger wrote:

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
