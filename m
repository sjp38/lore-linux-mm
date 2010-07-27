Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 0AFBD600815
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 19:10:54 -0400 (EDT)
Date: Tue, 27 Jul 2010 16:10:49 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: Check NULL pointer Dereference in mm/filemap.c
Message-Id: <20100727161049.eeac8c7c.akpm@linux-foundation.org>
In-Reply-To: <20100726082542.GA2646@localhost.localdomain>
References: <20100726082542.GA2646@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: wzt.wzt@gmail.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 26 Jul 2010 16:25:42 +0800
wzt.wzt@gmail.com wrote:

> mapping->a_ops->direct_IO() is not checked, if it's a NULL pointer, 
> that will casue an oops. pagecache_write_begin/end is exported to
> other functions, so they need to check null pointer before use them. 
> 

The patch checks a lot more things than ->directIO!

It would be best to not add this overhead if possible.  Did you
actually observe an oops?  If so, please fully describe it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
