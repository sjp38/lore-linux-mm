Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 4D6426B00A1
	for <linux-mm@kvack.org>; Sun, 18 Jan 2009 14:42:24 -0500 (EST)
Subject: Re: [Patch] slob: clean up the code
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <20090118180038.GB3292@hack.private>
References: <20090118180038.GB3292@hack.private>
Content-Type: text/plain; charset=utf-8
Date: Sun, 18 Jan 2009 13:41:58 -0600
Message-Id: <1232307718.5202.14.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: =?ISO-8859-1?Q?Am=E9rico?= Wang <xiyou.wangcong@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, cl@linux-foundation.org, penberg@cs.helsinki.fi, linux-mm@kvack.org, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2009-01-19 at 02:00 +0800, AmA(C)rico Wang wrote:
> - Use NULL instead of plain 0;

Good.

> - Rename slob_page() to is_slob_page();

Ok.

> - Define slob_page() to convert void* to struct slob_page*;

Ok. The general "struct page vs page" confusion isn't really improved by
this but at least this makes it a bit less ugly.

> - Rename slob_new_page() to slob_new_pages();

Don't care about this one. We've long had a notion of a "high order
page" (singular) of size 2^n pages.

> - Define slob_free_pages() accordingly.

This is a trivial wrapper function with one user.

But this patch is probably fine in it's current form, I don't care
enough about the above to respin it.

Signed-off-by: Matt Mackall <mpm@selenic.com>

-- 
http://selenic.com : development and support for Mercurial and Linux


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
