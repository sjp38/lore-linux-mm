Date: Fri, 5 Jan 2001 13:54:59 -0200 (BRST)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: MM/VM todo list
In-Reply-To: <Pine.LNX.4.21.0101051505430.1295-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.21.0101051344270.2745-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 5 Jan 2001, Rik van Riel wrote:

> Hi,
> 
> here is a TODO list for the memory management area of the
> Linux kernel, with both trivial things that could be done
> for later 2.4 releases and more complex things that really
> have to be 2.5 things.
> 
> Most of these can be found on http://linux24.sourceforge.net/ too
> 
> Trivial stuff:
> * VM: better IO clustering for swap (and filesystem) IO
>   * Marcelo's swapin/out clustering code
    * Swap space preallocation at try_to_swap_out()

>   * ->writepage() IO clustering support

Hum, IMO this should be in the "2.5" list because 

1) It involves changes to the PageDirty scheme if we want to support write
clustering for normal writes, and not only shared writable mappings like
we do now. (basically this changes are in Chris Mason's patch)

2) It involves changes to the filesystem code if we want to support
generic write clustering for fs's which use block_write_full_page.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
