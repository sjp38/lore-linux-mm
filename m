Date: Thu, 7 Jun 2001 16:44:06 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH] Reap dead swap cache earlier v2
In-Reply-To: <15135.37871.373389.465893@gargle.gargle.HOWL>
Message-ID: <Pine.LNX.4.21.0106071640410.1596-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: John Stoffel <stoffel@casc.com>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 7 Jun 2001, John Stoffel wrote:
> Shouldn't the "swap_count(page) == 1" check be earlier in the if
> statement, so we can fall through more quickly if there is no work to
> be done?  A small optimization, but putting the common cases first
> will help.

I don't think so: the out-of-line swap_count() function is considerably
more complicated than the macros and inline functions tested before it.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
