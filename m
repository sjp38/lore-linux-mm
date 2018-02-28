Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 493356B0007
	for <linux-mm@kvack.org>; Wed, 28 Feb 2018 18:22:59 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id n73so4351059itg.0
        for <linux-mm@kvack.org>; Wed, 28 Feb 2018 15:22:59 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id d82si1637192ioe.114.2018.02.28.15.22.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 28 Feb 2018 15:22:58 -0800 (PST)
Subject: Re: [PATCH v3 0/4] Split page_type out from mapcount
References: <20180228223157.9281-1-willy@infradead.org>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <06c145aa-db40-df72-b626-da9d45f9111d@infradead.org>
Date: Wed, 28 Feb 2018 15:22:49 -0800
MIME-Version: 1.0
In-Reply-To: <20180228223157.9281-1-willy@infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-kernel@vger.kernel.org

On 02/28/2018 02:31 PM, Matthew Wilcox wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> I want to use the _mapcount field to record what a page is in use as.
> This can help with debugging and we can also expose that information to
> userspace through /proc/kpageflags to help diagnose memory usage (not
> included as part of this patch set).

Hey,

Will there be updates to tools/vm/ also, or are these a different set of
(many) flags?

thanks,
-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
