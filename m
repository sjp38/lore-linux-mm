Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f176.google.com (mail-pf0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 1742482963
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 17:48:26 -0500 (EST)
Received: by mail-pf0-f176.google.com with SMTP id w123so21538311pfb.0
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 14:48:26 -0800 (PST)
Received: from mail-pf0-x22a.google.com (mail-pf0-x22a.google.com. [2607:f8b0:400e:c00::22a])
        by mx.google.com with ESMTPS id gl10si11903887pac.164.2016.02.03.14.48.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Feb 2016 14:48:25 -0800 (PST)
Received: by mail-pf0-x22a.google.com with SMTP id w123so21538079pfb.0
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 14:48:25 -0800 (PST)
Date: Wed, 3 Feb 2016 14:48:23 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v4 2/4] x86: query dynamic DEBUG_PAGEALLOC setting
In-Reply-To: <1454488775-108777-3-git-send-email-borntraeger@de.ibm.com>
Message-ID: <alpine.DEB.2.10.1602031447430.10331@chino.kir.corp.google.com>
References: <1454488775-108777-1-git-send-email-borntraeger@de.ibm.com> <1454488775-108777-3-git-send-email-borntraeger@de.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian Borntraeger <borntraeger@de.ibm.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>

On Wed, 3 Feb 2016, Christian Borntraeger wrote:

> We can use debug_pagealloc_enabled() to check if we can map
> the identity mapping with 2MB pages. We can also add the state
> into the dump_stack output.
> 
> The patch does not touch the code for the 1GB pages, which ignored
> CONFIG_DEBUG_PAGEALLOC. Do we need to fence this as well?
> 

I think it would be an extension of the debug_pagealloc= functionality and 
can certainly be introduced if someone is inclined.

> Signed-off-by: Christian Borntraeger <borntraeger@de.ibm.com>
> Reviewed-by: Thomas Gleixner <tglx@linutronix.de>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
