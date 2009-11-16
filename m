Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 295F46B004D
	for <linux-mm@kvack.org>; Mon, 16 Nov 2009 12:08:56 -0500 (EST)
Date: Mon, 16 Nov 2009 09:09:04 -0800 (PST)
From: Vincent Li <macli@brc.ubc.ca>
Subject: Re: [PATCH] vmscan: correct comment type error in
 scan_zone_unevictable_pages
In-Reply-To: <1258351627-25186-1-git-send-email-macli@brc.ubc.ca>
Message-ID: <alpine.DEB.2.00.0911160905400.30997@kernalhack.brc.ubc.ca>
References: <1258351627-25186-1-git-send-email-macli@brc.ubc.ca>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Vincent Li <macli@brc.ubc.ca>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>



On Sun, 15 Nov 2009, Vincent Li wrote:

>   * Scan @zone's unevictable LRU lists to check for pages that have become
> - * evictable.  Move those that have to @zone's inactive list where they
> + * evictable.  Move those to @zone's inactive list where they

Oops, after re-reading the comment this morning, it seems ok, 
should go back to school to brush up my English :). Sorry.

Vincent

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
