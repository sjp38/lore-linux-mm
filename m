Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id C66486B20DB
	for <linux-mm@kvack.org>; Tue, 20 Nov 2018 11:25:33 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id w7-v6so1841591plp.9
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 08:25:33 -0800 (PST)
Received: from ms.lwn.net (ms.lwn.net. [45.79.88.28])
        by mx.google.com with ESMTPS id m7si43393385pgi.547.2018.11.20.08.25.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Nov 2018 08:25:32 -0800 (PST)
Date: Tue, 20 Nov 2018 09:25:30 -0700
From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: [PATCH] docs/mm: update kmalloc kernel-doc description
Message-ID: <20181120092530.5620a924@lwn.net>
In-Reply-To: <1541954924-21471-1-git-send-email-rppt@linux.ibm.com>
References: <1541954924-21471-1-git-send-email-rppt@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Randy Dunlap <rdunlap@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, linux-doc@vger.kernel.org, linux-mm@kvack.org

On Sun, 11 Nov 2018 18:48:44 +0200
Mike Rapoport <rppt@linux.ibm.com> wrote:

> Add references to GFP documentation and the memory-allocation.rst and remove
> GFP_USER, GFP_DMA and GFP_NOIO descriptions.
> 
> While on it slightly change the formatting so that the list of GFP flags
> will be rendered as "description" in the generated html.
> 
> Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
> ---
> 
> Probably this should go via the -mm tree as it touches include/linux/slab.h

A week and some later it's not there - Andrew is even slower than me, it
seems! :)  So I went ahead and applied it, fixing the conflict over the
addition of the memory_allocation label while I was at it.

Thanks,

jon
