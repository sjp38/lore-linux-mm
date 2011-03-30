Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id B6B358D0040
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 18:53:18 -0400 (EDT)
Date: Wed, 30 Mar 2011 15:53:16 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: fix setup_zone_pageset section mismatch
Message-Id: <20110330155316.e11d760c.akpm@linux-foundation.org>
In-Reply-To: <4D93B302.9090103@oracle.com>
References: <20110324132435.4ee9694e.randy.dunlap@oracle.com>
	<20110330150510.bc02d041.akpm@linux-foundation.org>
	<4D93B302.9090103@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <randy.dunlap@oracle.com>
Cc: linux-mm@kvack.org, Paul Mundt <lethal@linux-sh.org>

On Wed, 30 Mar 2011 15:47:30 -0700
Randy Dunlap <randy.dunlap@oracle.com> wrote:

> ...
>
> > 
> > I already merged Paul Mundt's patch whcih marks build_all_zonelists()
> > as __ref.  That seems a better solution?
> 
> Merged where?  mmotm?

mm.  

--- a/mm/page_alloc.c~mm-page_allocc-silence-build_all_zonelists-section-mismatch
+++ a/mm/page_alloc.c
@@ -3170,7 +3170,7 @@ static __init_refok int __build_all_zone
  * Called with zonelists_mutex held always
  * unless system_state == SYSTEM_BOOTING.
  */
-void build_all_zonelists(void *data)
+void __ref build_all_zonelists(void *data)
 {
 	set_zonelist_order();
 
_


>
> ...
> 
> > If we'd handled the section via
> > 
> > #ifdef CONFIG_MEMORY_HOTPLUG
> > #define __meminit
> > #else
> > #define __meminit __init
> > #endif
> > 
> > of similar then that would fix things.  iirc we used to do it that
> > way...
> 
> Yes, that older way made more sense to me.

I guess it was too simple.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
