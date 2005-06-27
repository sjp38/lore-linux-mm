Date: Mon, 27 Jun 2005 10:49:24 -0700 (PDT)
From: Christoph Lameter <christoph@lameter.com>
Subject: Re: [rfc] lockless pagecache
In-Reply-To: <20050627004624.53f0415e.akpm@osdl.org>
Message-ID: <Pine.LNX.4.62.0506271048260.19550@graphe.net>
References: <42BF9CD1.2030102@yahoo.com.au> <20050627004624.53f0415e.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 27 Jun 2005, Andrew Morton wrote:

> Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> >
> > First I'll put up some numbers to get you interested - of a 64-way Altix
> >  with 64 processes each read-faulting in their own 512MB part of a 32GB
> >  file that is preloaded in pagecache (with the proper NUMA memory
> >  allocation).
> 
> I bet you can get a 5x to 10x reduction in ->tree_lock traffic by doing
> 16-page faultahead.

Could be working into the prefault patch.... Good idea.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
