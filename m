Message-ID: <4891C8BC.1020509@linux-foundation.org>
Date: Thu, 31 Jul 2008 09:14:20 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: [PATCH] Update Unevictable LRU and Mlocked Pages documentation
References: <1217452439.7676.26.camel@lts-notebook>
In-Reply-To: <1217452439.7676.26.camel@lts-notebook>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

> +Why maintain unevictable pages on an additional LRU list?  Primarily because
> +we want to be able to migrate unevictable pages between nodes--for memory
> +deframentation, workload management and memory hotplug.  The linux kernel can
> +only migrate pages that it can successfully isolate from the lru lists.
> +Therefore, we want to keep the unevictable pages on an lru-like list, where
> +they can be found by isolate_lru_page().

The primary motivation for me was to get rid of the useless scanning of pages under memory pressure which led to live lock scenarios. mlocked pages are migratable now so the changes do not really change anything there. The unevictable lists are also necessary to spill pages back to the regular LRUs when unevictable pages become evictable again.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
