Date: Mon, 11 Sep 2006 20:01:20 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: A solution for more GFP_xx flags?
In-Reply-To: <45061F16.202@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0609111957510.7923@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0609111920590.7815@schroedinger.engr.sgi.com>
 <45061F16.202@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 12 Sep 2006, Nick Piggin wrote:

> This seems like a decent approach to make a nice general interface. I guess
> existing APIs can be easily implemented by filling in the structure. If you
> took this approach I don't think there should be any objections.
> 
> A minor point: would we prefer a struct argument to the allocator, or more
> function arguments? It is an API that we need to get right...

If you look at my allocator API (see the latest slab patchset), one could 
add all the allocator methods into the struct in order to objectivize the 
page alloator.

The logical first step towards that would be to have a struct argument
to allow detailed allocation control and to avoid this contextual
memory policy / cpuset mess.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
