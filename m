Date: Mon, 24 Apr 2000 22:27:02 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: pressuring dirty pages (2.3.99-pre6)
Message-ID: <20000424222702.C3389@redhat.com>
References: <Pine.LNX.4.21.0004241650140.5572-200000@duckman.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.4.21.0004241650140.5572-200000@duckman.conectiva>; from riel@conectiva.com.br on Mon, Apr 24, 2000 at 04:54:38PM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@nl.linux.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, Apr 24, 2000 at 04:54:38PM -0300, Rik van Riel wrote:
> 
> I've been trying to fix the VM balance for a week or so now,
> and things are mostly fixed except for one situation.
> 
> If there is a *heavy* write going on and the data is in the
> page cache only .. ie. no buffer heads available, then the
> page cache will grow almost without bounds and kswapd and
> the rest of the system will basically spin in shrink_mmap()...

shrink_mmap is the problem then -- it should be giving up
sooner and letting try_to_swap_out() deal with the pages.  mmap()ed
dirty pages can only be freed through swapper activity, not via
shrink_mmap().

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
