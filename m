Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f180.google.com (mail-ie0-f180.google.com [209.85.223.180])
	by kanga.kvack.org (Postfix) with ESMTP id 970856B0038
	for <linux-mm@kvack.org>; Fri, 10 Jul 2015 10:19:17 -0400 (EDT)
Received: by iebmu5 with SMTP id mu5so196702975ieb.1
        for <linux-mm@kvack.org>; Fri, 10 Jul 2015 07:19:17 -0700 (PDT)
Received: from resqmta-ch2-04v.sys.comcast.net (resqmta-ch2-04v.sys.comcast.net. [69.252.207.36])
        by mx.google.com with ESMTPS id s9si1522621ign.77.2015.07.10.07.19.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 10 Jul 2015 07:19:15 -0700 (PDT)
Date: Fri, 10 Jul 2015 09:19:11 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [patch] mm/slub: Move slab initialization into irq enabled
 region
In-Reply-To: <20150710120259.836414367@linutronix.de>
Message-ID: <alpine.DEB.2.11.1507100918380.5980@east.gentwo.org>
References: <20150710120259.836414367@linutronix.de>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: LKML <linux-kernel@vger.kernel.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Steven Rostedt <rostedt@goodmis.org>, Peter Zijlstra <peterz@infradead.org>

There is a duplicate check for page == NULL now.


Subject: slub: allocate_slab: no need to check twice for page == NULL

Remove the second check.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c
+++ linux/mm/slub.c
@@ -1396,9 +1396,6 @@ static struct page *allocate_slab(struct
 			kmemcheck_mark_unallocated_pages(page, pages);
 	}

-	if (!page)
-		goto out;
-
 	page->objects = oo_objects(oo);

 	order = compound_order(page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
