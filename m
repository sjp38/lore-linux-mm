Date: Wed, 31 Jan 2001 10:21:58 +0000
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: [PATCH] vma limited swapin readahead
Message-ID: <20010131102158.O11607@redhat.com>
References: <Pine.LNX.4.21.0101310037540.16187-100000@freak.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0101310037540.16187-100000@freak.distro.conectiva>; from marcelo@conectiva.com.br on Wed, Jan 31, 2001 at 01:05:02AM -0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Jan 31, 2001 at 01:05:02AM -0200, Marcelo Tosatti wrote:
> 
> However, the pages which are contiguous on swap are not necessarily
> contiguous in the virtual memory area where the fault happened. That means
> the swapin readahead code may read pages which are not related to the
> process which suffered a page fault.
> 
Yes, but reading extra sectors is cheap, and throwing the pages out of
memory again if they turn out not to be needed is also cheap.  The
on-disk swapped pages are likely to have been swapped out at roughly
the same time, which is at least a modest indicator of being of the
same age and likely to have been in use at the same time in the past.

I'd like to see at lest some basic performance numbers on this,
though.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
