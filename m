Date: Thu, 10 May 2001 21:19:13 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: [PATCH] allocation looping + kswapd CPU cycles
Message-ID: <20010510211913.R16590@redhat.com>
References: <20010510205204.O16590@redhat.com> <Pine.LNX.4.21.0105101517050.19732-100000@freak.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0105101517050.19732-100000@freak.distro.conectiva>; from marcelo@conectiva.com.br on Thu, May 10, 2001 at 03:22:57PM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Mark Hemment <markhe@veritas.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, May 10, 2001 at 03:22:57PM -0300, Marcelo Tosatti wrote:

> Initially I thought about __GFP_FAIL to be used by writeout routines which
> want to cluster pages until they can allocate memory without causing any
> pressure to the system. Something like this: 
> 
> while ((page = alloc_page(GFP_FAIL))
> 	add_page_to_cluster(page);
> write_cluster(); 

Isn't that an orthogonal decision?  You can use __GFP_FAIL with or
without __GFP_WAIT or __GFP_IO, whichever is appropriate.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
