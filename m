Date: Thu, 10 May 2001 20:52:04 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: [PATCH] allocation looping + kswapd CPU cycles
Message-ID: <20010510205204.O16590@redhat.com>
References: <Pine.LNX.4.21.0105100935040.31900-100000@alloc> <Pine.LNX.4.21.0105101341130.19732-100000@freak.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0105101341130.19732-100000@freak.distro.conectiva>; from marcelo@conectiva.com.br on Thu, May 10, 2001 at 01:43:46PM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: Mark Hemment <markhe@veritas.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, May 10, 2001 at 01:43:46PM -0300, Marcelo Tosatti wrote:

> No. __GFP_FAIL can to try to reclaim pages from inactive clean.
> 
> We just want to avoid __GFP_FAIL allocations from going to
> try_to_free_pages().

Why?  __GFP_FAIL is only useful as an indication that the caller has
some magic mechanism for coping with failure.  There's no other
information passed, so a brief call to try_to_free_pages is quite
appropriate.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
