Date: Thu, 10 May 2001 09:41:45 +0100 (BST)
From: Mark Hemment <markhe@veritas.com>
Subject: Re: [PATCH] allocation looping + kswapd CPU cycles 
In-Reply-To: <Pine.LNX.4.21.0105091334540.13878-100000@freak.distro.conectiva>
Message-ID: <Pine.LNX.4.21.0105100935040.31900-100000@alloc>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 9 May 2001, Marcelo Tosatti wrote:
> On Wed, 9 May 2001, Mark Hemment wrote:
> >   Could introduce another allocation flag (__GFP_FAIL?) which is or'ed
> > with a __GFP_WAIT to limit the looping?
> 
> __GFP_FAIL is in the -ac tree already and it is being used by the bounce
> buffer allocation code. 

Thanks for the pointer.

  For non-zero order allocations, the test against __GFP_FAIL is a little
too soon; it would be better after we've tried to reclaim pages from the
inactive-clean list.  Any nasty side effects to this?

  Plus, the code still prevents PF_MEMALLOC processes from using the
inactive-clean list for non-zero order allocations.  As the trend seems to
be to make zero and non-zero allocations 'equivalent', shouldn't this
restriction to lifted?

Mark

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
