Date: Thu, 5 Aug 2004 23:19:38 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] 3/4: writeout watermarks
Message-Id: <20040805231938.6d87476c.akpm@osdl.org>
In-Reply-To: <4113218F.5050803@yahoo.com.au>
References: <41130FB1.5020001@yahoo.com.au>
	<41130FD2.5070608@yahoo.com.au>
	<41131105.8040108@yahoo.com.au>
	<20040805222733.477b3017.akpm@osdl.org>
	<41131862.5050000@yahoo.com.au>
	<20040805224920.6755198d.akpm@osdl.org>
	<4113218F.5050803@yahoo.com.au>
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
>  Basically what the above code, is scale the dirty_ratio with the
>  amount of unmapped pages, however it doesn't also scale the
>  dirty_background_ratio (it does after my patch).

OK, that makes sense.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
