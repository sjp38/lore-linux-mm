Date: Fri, 19 Oct 2001 11:03:12 -0200 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [RFC][PATCH] free more swap space on exit()
In-Reply-To: <Pine.LNX.4.21.0110191157110.939-100000@localhost.localdomain>
Message-ID: <Pine.LNX.4.33L.0110191100570.3690-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 19 Oct 2001, Hugh Dickins wrote:

> Please just find_get_page and TryLockPage within
> free_swap_and_swap_cache?

I really don't like the idea of sprinkling the magic all
around the VM subsystem, but prefer to keep the code
easier to maintain instead.

About the "undoes some inlining", I guess we might as
well mark __find_get_page() inline then so it gets
included into __find_lock_page(), after all it's the
equivalent code so it should end up the same as before.

regards,

Rik
-- 
DMCA, SSSCA, W3C?  Who cares?  http://thefreeworld.net/  (volunteers needed)

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
