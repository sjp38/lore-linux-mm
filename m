Date: Thu, 10 May 2001 21:52:41 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: [PATCH] allocation looping + kswapd CPU cycles
Message-ID: <20010510215241.S16590@redhat.com>
References: <20010510211913.R16590@redhat.com> <Pine.LNX.4.21.0105101545140.19732-100000@freak.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0105101545140.19732-100000@freak.distro.conectiva>; from marcelo@conectiva.com.br on Thu, May 10, 2001 at 03:49:05PM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Mark Hemment <markhe@veritas.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, May 10, 2001 at 03:49:05PM -0300, Marcelo Tosatti wrote:

> Back to the main discussion --- I guess we could make __GFP_FAIL (with
> __GFP_WAIT set :)) allocations actually fail if "try_to_free_pages()" does
> not make any progress (ie returns zero). But maybe thats a bit too
> extreme.

That would seem to be a reasonable interpretation of __GFP_FAIL +
__GFP_WAIT, yes.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
