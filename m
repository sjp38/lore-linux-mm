Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2FB636B005C
	for <linux-mm@kvack.org>; Fri, 21 Aug 2009 11:18:16 -0400 (EDT)
Received: from imap1.linux-foundation.org (imap1.linux-foundation.org [140.211.169.55])
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id n7LFIIm2001931
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Fri, 21 Aug 2009 08:18:20 -0700
Date: Thu, 20 Aug 2009 16:00:24 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/vmscan: rename zone_nr_pages() to
 zone_lru_nr_pages()
Message-Id: <20090820160024.6e24dbb7.akpm@linux-foundation.org>
In-Reply-To: <1250793774-7969-1-git-send-email-macli@brc.ubc.ca>
References: <1250793774-7969-1-git-send-email-macli@brc.ubc.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Vincent Li <macli@brc.ubc.ca>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 20 Aug 2009 11:42:54 -0700
Vincent Li <macli@brc.ubc.ca> wrote:

> Name zone_nr_pages can be mis-read as zone's (total) number pages, but it actually returns
> zone's LRU list number pages.

Fair enough.

> -static unsigned long zone_nr_pages(struct zone *zone, struct scan_control *sc,
> +static unsigned long zone_lru_nr_pages(struct zone *zone, struct scan_control *sc,

Wouldn't zone_nr_lru_pages() be better?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
