Date: Thu, 5 Aug 2004 22:19:58 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] 1/4: rework alloc_pages
Message-Id: <20040805221958.49049229.akpm@osdl.org>
In-Reply-To: <41130FB1.5020001@yahoo.com.au>
References: <41130FB1.5020001@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nick Piggin <nickpiggin@yahoo.com.au> wrote:
>
> Previously the ->protection[] logic was broken. It was difficult to follow
>  and basically didn't use the asynch reclaim watermarks properly.

eh?

Broken how?

What is an "asynch reclaim watermark"?

>  This one uses ->protection only for lower-zone protection, and gives the
>  allocator flexibility to add the watermarks as desired.

eh?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
