Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 126366B0005
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 10:03:29 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id u188so69428062wmu.1
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 07:03:29 -0800 (PST)
Received: from lb2-smtp-cloud6.xs4all.net (lb2-smtp-cloud6.xs4all.net. [194.109.24.28])
        by mx.google.com with ESMTPS id 201si24872530wml.102.2016.01.25.07.03.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 25 Jan 2016 07:03:28 -0800 (PST)
Message-ID: <1453734204.17181.15.camel@tiscali.nl>
Subject: Re: [PATCH v2] mm/debug_pagealloc: Ask users for default setting of
 debug_pagealloc
From: Paul Bolle <pebolle@tiscali.nl>
Date: Mon, 25 Jan 2016 16:03:24 +0100
In-Reply-To: <1453720528-103788-1-git-send-email-borntraeger@de.ibm.com>
References: <1453720528-103788-1-git-send-email-borntraeger@de.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian Borntraeger <borntraeger@de.ibm.com>
Cc: peterz@infradead.org, heiko.carstens@de.ibm.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org

On ma, 2016-01-25 at 12:15 +0100, Christian Borntraeger wrote:
> --- a/mm/Kconfig.debug
> +++ b/mm/Kconfig.debug

> +config DEBUG_PAGEALLOC_ENABLE_DEFAULT
> +	bool "Enable debug page memory allocations by default?"
> +        default off

Nit: you apparently meant
	default n

Note that "default off" should also evaluate to "n", which probably
explains why you didn't notice. And "n" is the default anyhow.

So I'm guessing you might as well drop this line.

> +        depends on DEBUG_PAGEALLOC
> +        ---help---
> +	  Enable debug page memory allocations by default? This value
> +	  can be overridden by debug_pagealloc=off|on.
> +
> +	  If unsure say no.

(Really trivial: you start indentation both with spaces and with tabs.
Start with tabs, please.)


Paul Bolle

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
