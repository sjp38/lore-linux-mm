From: David Woodhouse <dwmw2@infradead.org>
In-Reply-To: <200006281554.KAA19007@jen.americas.sgi.com> 
References: <200006281554.KAA19007@jen.americas.sgi.com> 
Subject: Re: kmap_kiobuf() 
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Date: Wed, 28 Jun 2000 17:06:30 +0100
Message-ID: <13214.962208390@cygnus.co.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: lord@sgi.com
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, sct@redhat.com, riel@conectiva.com.br
List-ID: <linux-mm.kvack.org>

lord@sgi.com said:
>  I always knew it would go down like a ton of bricks, because of the
> TLB flushing costs. As soon as you have a multi-cpu box this operation
> gets expensive, the code could be changed to do lazy tlb flushes on
> unmapping the pages, but you still have the cost every time you set a
> mapping up. 

Aha - is this why kmap uses a pre-allocated set of PTEs? I got about that 
far before deciding I had no clue what was going on and giving up.

MM is not exactly my field - I just know I want to be able to lock down a 
user's buffer and treat it as if it were in kernel-space, passing its 
address to functions which expect kernel buffers.

--
dwmw2


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
