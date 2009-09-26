Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 05FB06B005C
	for <linux-mm@kvack.org>; Sat, 26 Sep 2009 07:58:45 -0400 (EDT)
Date: Sat, 26 Sep 2009 12:58:53 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [RFC][PATCH] HWPOISON: remove the unsafe __set_page_locked()
In-Reply-To: <20090926114806.GA12419@localhost>
Message-ID: <Pine.LNX.4.64.0909261251090.15781@sister.anvils>
References: <20090926031537.GA10176@localhost> <Pine.LNX.4.64.0909261115530.12927@sister.anvils>
 <20090926114806.GA12419@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Andi Kleen <andi@firstfloor.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Sat, 26 Sep 2009, Wu Fengguang wrote:
> 
> However we may well end up to accept the fact that "we just cannot do
> hwpoison 100% correct", and settle with a simple and 99% correct code.

I thought we already accepted that: you cannot do hwpoison 100% correct
(or not without a radical rewrite of the OS); you're just looking to
get it right almost all the time on those systems which have almost
all their pages in pagecache or userspace or free.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
