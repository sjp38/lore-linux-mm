Date: Tue, 15 Feb 2005 17:41:09 -0800
From: Paul Jackson <pj@sgi.com>
Subject: Re: manual page migration -- issue list
Message-Id: <20050215174109.238b7135.pj@sgi.com>
In-Reply-To: <42128B25.9030206@sgi.com>
References: <42128B25.9030206@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Bryant <raybry@sgi.com>
Cc: linux-mm@kvack.org, holt@sgi.com, ak@muc.de, haveblue@us.ibm.com, marcello@cyclades.com, stevel@mwwireless.net, peterc@gelato.unsw.edu.au
List-ID: <linux-mm.kvack.org>

A couple comments in response to Andi's earlier post on the
related lkml thread ...

Andi wrote:
> Sorry, but the only real difference between your API and mbind is that
> yours has a pid argument. 

One other difference shouts out at me.  I am unsure of my reading of
Andi's post, so I can't tell if (1) it was so obvious Andi didn't
bother mentioning it, or (2) he doesn't see it as a difference.

That difference is this.

    The various numa mechanisms, such as mbind, set_mempolicy and cpusets,
    as well as the simple first touch that MPI jobs rely on, are all about
    setting a policy for where future allocations should go.

    This page migration mechanism is all about changing the placement of
    physical pages of ram that are currently allocated.

At any point in time, numa policy guides future allocations, and page
migration redoes past allocations.


Andi wrote:
> My thinking is the simplest way to handle that is to have a call that just
> migrates everything. 

I might have ended up at the same place, not sure, when I just suggested
in my previous post:

pj wrote:
> As a straw man, let me push the factored migration call to the
> extreme, and propose a call:
> 
>   sys_page_migrate(pid, oldnode, newnode)
> 
> that moves any physical page in the address space of pid that is
> currently located on oldnode to newnode.


-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.650.933.1373, 1.925.600.0401
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
