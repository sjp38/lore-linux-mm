Date: Sat, 25 Aug 2001 11:35:45 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: SWAP_MAP_MAX: How?
In-Reply-To: <20010824140749.C4389@redhat.com>
Message-ID: <Pine.LNX.4.21.0108251118150.1584-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Andrea Arcangeli <andrea@suse.de>, Ben LaHaise <bcrl@redhat.com>, Marcelo Tosatti <marcelo@conectiva.com.br>, Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 24 Aug 2001, Stephen C. Tweedie wrote:
> 
> There _was_ once a way to do this --- mmap()ing another process's
> /proc/*/mem would allow you to get a swap page mapped into memory
> multiple times, but we removed support for that way back in pre-2.2
> days.  I don't think we allow that any more, unless it's been
> reenabled again.

(Apologies if I've taken too much context away there - I'd
like to force a rebuttal if any, flames to me not to Stephen.)

Thanks a lot, Stephen.  I've waited awhile to see whether anyone else
dissents, but silence.  I'm going to assume that SWAP_MAP_MAX cannot 
actually happen in 2.4 at present.  I'm not going to remove any code
that relates to it (unless asked to), it might be needed again the
day after tomorrow or whenever.  But I shall not put any more effort
into handling that case correctly in try_to_unuse(),
beyond commenting the issues related to it.

Thanks again,
Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
