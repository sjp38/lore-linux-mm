Date: Mon, 23 Jul 2001 19:41:53 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: Swap progress accounting
Message-ID: <20010723194153.J31712@redhat.com>
References: <Pine.LNX.4.33L.0107231425190.20326-100000@duckman.distro.conectiva> <Pine.LNX.4.33L.0107231534070.20326-100000@duckman.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.33L.0107231534070.20326-100000@duckman.distro.conectiva>; from riel@conectiva.com.br on Mon, Jul 23, 2001 at 03:35:28PM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Arjan van de Ven <arjanv@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, Jul 23, 2001 at 03:35:28PM -0300, Rik van Riel wrote:

> OK, after talking on IRC it turns out that recursive allocations
> are failing.
> 
> This isn't influenced by either changing __alloc_pages() or
> by changing swap_out(). What we need to do is limit the amount
> of recursive allocations going on at the same time, probably
> by making the system sleep on IO completion instead of looping
> like crazy in __alloc_pages()/page_launder() until we run out
> of all our memory ...

That's very much the sort of thing that the reservation proposal from
a few weeks back was designed to address --- serialising access to the
last few free pages to allow the VM to proceed OK.

One gotcha is that there may be specific processes, such as loopd or
nbd servers, that need to be allowed to proceed because otherwise you
risk blocking IO requests in other independent tasks.  

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
