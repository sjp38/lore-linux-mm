Date: Mon, 5 Aug 2002 03:50:18 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: how not to write a search algorithm
Message-ID: <20020805105018.GA15832@holomorphy.com>
References: <Pine.LNX.4.44L.0208041015350.23404-100000@imladris.surriel.com> <3D4D87CE.25198C28@zip.com.au> <20020804203804.GD4010@holomorphy.com> <3D4D9802.D1F208F0@zip.com.au> <20020804220218.GF4010@holomorphy.com> <3D4DAE2C.F45BC9D4@zip.com.au> <20020804224736.GI4010@holomorphy.com> <3D4DEA4B.4BAB65FB@zip.com.au> <20020805074042.GL4010@holomorphy.com> <3D4E3AD6.2010A02B@zip.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3D4E3AD6.2010A02B@zip.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: Rik van Riel <riel@conectiva.com.br>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Aug 05, 2002 at 01:44:06AM -0700, Andrew Morton wrote:
> The nice thing is that it 99% leverages a per-cpu-pages mechanism.
> We'd have to make fill_up_the_per_cpu_buffer() loop for ever
> (but the page allocator does that anyway) or handle a failure
> from that.  Just loop, I'd say.  Provided the caller isn't holding any
> semaphores.

It should hold the mm->mmap_sem


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
