Date: Wed, 10 Oct 2001 16:48:23 -0400
From: Benjamin LaHaise <bcrl@redhat.com>
Subject: Re: [CFT][PATCH] smoother VM for -ac
Message-ID: <20011010164823.A17860@redhat.com>
References: <Pine.LNX.4.33L.0110101710150.26495-100000@duckman.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.33L.0110101710150.26495-100000@duckman.distro.conectiva>; from riel@conectiva.com.br on Wed, Oct 10, 2001 at 05:25:30PM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: kernelnewbies@nl.linux.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alan Cox <alan@lxorguk.ukuu.org.uk>
List-ID: <linux-mm.kvack.org>

On Wed, Oct 10, 2001 at 05:25:30PM -0300, Rik van Riel wrote:
> 4) in page_alloc.c, the "slowdown" reschedule has been
>    made stronger by turning it into a try_to_free_pages(),
>    under memory load, this results in allocators calling
>    try_to_free_pages() when the amount of work to be done
>    isn't too bad yet and pretty much guarantees them they'll
>    get to do their allocation immediately afterwards ...
>    statistics make sure that the memory hogs are slowed down
>    much more than well-behaved programs

There's a small problem with this one: I know that during testing of 
earlier 2.4 kernels we saw a livelock which was caused by the vm 
subsystem spinning without scheduling.  This can happen in a couple of 
cases like NFS where another task has to be allowed to run in order to 
make progress in clearing pages.

		-ben
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
