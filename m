Date: Fri, 24 Aug 2001 14:07:49 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: SWAP_MAP_MAX: How?
Message-ID: <20010824140749.C4389@redhat.com>
References: <20010824121951.A4389@redhat.com> <Pine.LNX.4.21.0108241323280.1044-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0108241323280.1044-100000@localhost.localdomain>; from hugh@veritas.com on Fri, Aug 24, 2001 at 01:42:59PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Andrea Arcangeli <andrea@suse.de>, Ben LaHaise <bcrl@redhat.com>, Marcelo Tosatti <marcelo@conectiva.com.br>, Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Fri, Aug 24, 2001 at 01:42:59PM +0100, Hugh Dickins wrote:

> Doesn't it need an anonymous page mapped multiple (e.g. 256) times
> into multiple (e.g. 256) mms to reach the limit?

That would do it, yes.

> And there's an obvious
> way that can happen, by multiply attaching a piece of IPC Shared Memory,
> and multiply forking.  But in that case it's the shared memory object
> which gets the large number of references, and the swap counts stay 1.

Indeed --- sysV shm swapping is eccentric. :-)

There _was_ once a way to do this --- mmap()ing another process's
/proc/*/mem would allow you to get a swap page mapped into memory
multiple times, but we removed support for that way back in pre-2.2
days.  I don't think we allow that any more, unless it's been
reenabled again.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
