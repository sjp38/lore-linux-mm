Date: Mon, 13 Sep 2004 20:31:05 -0300
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: [PATCH] Do not mark being-truncated-pages as cache hot
Message-ID: <20040913233104.GD23588@logos.cnet>
References: <20040913171037.793d4f68.akpm@osdl.org> <72070000.1095121472@flay>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <72070000.1095121472@flay>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, piggin@cyberone.com.au
List-ID: <linux-mm.kvack.org>

On Mon, Sep 13, 2004 at 05:24:32PM -0700, Martin J. Bligh wrote:
> > "Martin J. Bligh" <mbligh@aracnet.com> wrote:
> >> 
> >> > - Making the allocation policy FIFO should drastically increase the chances "hot" pages
> >>  > are handed to the allocator. AFAIK the policy now is LIFO.
> >> 
> >>  It should definitely have been FIFO to start with
> > 
> > I always intended that it be LIFO.  Take the hottest page, for heavens
> > sake.  As the oldest page is the one which is most likely to have fallen
> > out of cache then why a-priori choose it?
> 
> Bah. I just had my acronyms backwards ... I meant LIFO, sorry ;-)

I inverted both in the first email, I meant the other way around. Sorry :)
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
