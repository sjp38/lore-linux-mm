Date: Thu, 10 May 2001 15:49:05 -0300 (BRT)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: [PATCH] allocation looping + kswapd CPU cycles
In-Reply-To: <20010510211913.R16590@redhat.com>
Message-ID: <Pine.LNX.4.21.0105101545140.19732-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Mark Hemment <markhe@veritas.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Thu, 10 May 2001, Stephen C. Tweedie wrote:

> Hi,
> 
> On Thu, May 10, 2001 at 03:22:57PM -0300, Marcelo Tosatti wrote:
> 
> > Initially I thought about __GFP_FAIL to be used by writeout routines which
> > want to cluster pages until they can allocate memory without causing any
> > pressure to the system. Something like this: 
> > 
> > while ((page = alloc_page(GFP_FAIL))
> > 	add_page_to_cluster(page);
> > write_cluster(); 
> 
> Isn't that an orthogonal decision?  You can use __GFP_FAIL with or
> without __GFP_WAIT or __GFP_IO, whichever is appropriate.

Correct. 

Back to the main discussion --- I guess we could make __GFP_FAIL (with
__GFP_WAIT set :)) allocations actually fail if "try_to_free_pages()" does
not make any progress (ie returns zero). But maybe thats a bit too
extreme.

What do you think? 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
