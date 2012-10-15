Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id D6EED6B005D
	for <linux-mm@kvack.org>; Mon, 15 Oct 2012 16:51:13 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fa10so5910843pad.14
        for <linux-mm@kvack.org>; Mon, 15 Oct 2012 13:51:13 -0700 (PDT)
Date: Mon, 15 Oct 2012 13:51:10 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: huge_memory: Fix build error.
In-Reply-To: <20121015114456.GA30314@linux-mips.org>
Message-ID: <alpine.DEB.2.00.1210151349560.17947@chino.kir.corp.google.com>
References: <20121015114456.GA30314@linux-mips.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ralf Baechle <ralf@linux-mips.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-mips@linux-mips.org, David Daney <david.daney@cavium.com>

On Mon, 15 Oct 2012, Ralf Baechle wrote:

> Certain configurations won't implicitly pull in <linux/pagemap.h> resulting
> in the following build error:
> 
> mm/huge_memory.c: In function 'release_pte_page':
> mm/huge_memory.c:1697:2: error: implicit declaration of function 'unlock_page' [-Werror=implicit-function-declaration]
> mm/huge_memory.c: In function '__collapse_huge_page_isolate':
> mm/huge_memory.c:1757:3: error: implicit declaration of function 'trylock_page' [-Werror=implicit-function-declaration]
> cc1: some warnings being treated as errors
> 

This is because CONFIG_HUGETLB_PAGE=n so mempolicy.h doesn't include 
pagemap.h?

> Reported-by: David Daney <david.daney@cavium.com>
> Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
