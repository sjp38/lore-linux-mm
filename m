Date: Sat, 12 Nov 2005 14:34:11 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: [Lhms-devel] [Patch:RFC] New zone ZONE_EASY_RECLAIM[4/5]
In-Reply-To: <437384FB.1050804@austin.ibm.com>
References: <20051110190053.0236.Y-GOTO@jp.fujitsu.com> <437384FB.1050804@austin.ibm.com>
Message-Id: <20051112143133.0667.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Joel Schopp <jschopp@austin.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>, Linux Hotplug Memory Support <lhms-devel@lists.sourceforge.net>, Nick Piggin <nickpiggin@yahoo.com.au>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

> Yasunori Goto wrote:
> >
> > ===================================================================
> > --- new_zone.orig/include/linux/mmzone.h	2005-11-08 17:27:30.000000000 +0900
> > +++ new_zone/include/linux/mmzone.h	2005-11-08 17:27:37.000000000 +0900
> > @@ -92,6 +92,7 @@ struct per_cpu_pageset {
> >   * combinations of zone modifiers in "zone modifier space".
> >   */
> >  #define GFP_ZONEMASK	0x07
> > +
> >  /*
> >   * As an optimisation any zone modifier bits which are only valid when
> >   * no other zone modifier bits are set (loners) should be placed in
> > Index: new_zone/mm/mempolicy.c
> > ===================================================================
> 
> It looks like the only thing this patch changes in this file is whitespace

Oops. I made a mistake. Thanks. :-)


-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
