Date: Tue, 15 Mar 2005 13:29:52 -0300
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: [PATCH] Move code to isolate LRU pages into separate function
Message-ID: <20050315162952.GB12809@logos.cnet>
References: <20050314214941.GP3286@localhost> <20050315153754.GB12574@logos.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050315153754.GB12574@logos.cnet>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Hicks <mort@sgi.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Tue, Mar 15, 2005 at 12:37:54PM -0300, Marcelo Tosatti wrote:
> Hi Martin,
> 
> The -LHMS tree contains a similar "modularization" - which, however, 
> does not add the being-remove-pages to any linked list and does not 
> include the while loop.

Addition: it removes only one page from the LRU, thus it can be used
outside vmscan guts.
> 
> steal_page_from_lru() (the -mhp version) is much more generic. 
> 
> Check it out:
> http://sr71.net/patches/2.6.11/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
