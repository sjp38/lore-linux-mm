Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f178.google.com (mail-pf0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 1939A82963
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 17:50:35 -0500 (EST)
Received: by mail-pf0-f178.google.com with SMTP id o185so21464870pfb.1
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 14:50:35 -0800 (PST)
Received: from mail-pf0-x22e.google.com (mail-pf0-x22e.google.com. [2607:f8b0:400e:c00::22e])
        by mx.google.com with ESMTPS id hg4si11893434pac.180.2016.02.03.14.50.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Feb 2016 14:50:34 -0800 (PST)
Received: by mail-pf0-x22e.google.com with SMTP id 65so21488533pfd.2
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 14:50:34 -0800 (PST)
Date: Wed, 3 Feb 2016 14:50:33 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v4 4/4] x86: also use debug_pagealloc_enabled() for
 free_init_pages
In-Reply-To: <1454488775-108777-5-git-send-email-borntraeger@de.ibm.com>
Message-ID: <alpine.DEB.2.10.1602031448470.10331@chino.kir.corp.google.com>
References: <1454488775-108777-1-git-send-email-borntraeger@de.ibm.com> <1454488775-108777-5-git-send-email-borntraeger@de.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian Borntraeger <borntraeger@de.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>

On Wed, 3 Feb 2016, Christian Borntraeger wrote:

> we want to couple all debugging features with debug_pagealloc_enabled()
> and not with the config option CONFIG_DEBUG_PAGEALLOC.
> 
> Suggested-by: David Rientjes <rientjes@google.com>
> Signed-off-by: Christian Borntraeger <borntraeger@de.ibm.com>

Acked-by: David Rientjes <rientjes@google.com>

[+Joonsoo]

Joonso has indicated that he will work on converting other code using 
CONFIG_DEBUG_PAGEALLOC to instead consider debug_pagealloc_enabled(), so 
more work in this area will probably be forthcoming.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
