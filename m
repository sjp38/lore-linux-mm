Date: Mon, 19 Mar 2007 13:10:03 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 1/4] mm: move and rework isolate_lru_page
In-Reply-To: <20070312042602.5536.59068.sendpatchset@linux.site>
Message-ID: <Pine.LNX.4.64.0703191309460.8150@schroedinger.engr.sgi.com>
References: <20070312042553.5536.73828.sendpatchset@linux.site>
 <20070312042602.5536.59068.sendpatchset@linux.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Mon, 12 Mar 2007, Nick Piggin wrote:

> isolate_lru_page logically belongs to be in vmscan.c than migrate.c.

Acked-by: Christoph Lameter <clameter@sgi.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
