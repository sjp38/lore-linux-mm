Date: Sat, 6 Nov 2004 16:29:47 +0100
From: Andrea Arcangeli <andrea@novell.com>
Subject: Re: [PATCH] Remove OOM killer from try_to_free_pages /    all_unreclaimable braindamage
Message-ID: <20041106152947.GB3851@dualathlon.random>
References: <Pine.LNX.4.44.0411060944150.2721-100000@localhost.localdomain> <418CAD0C.3030109@cyberone.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <418CAD0C.3030109@cyberone.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <piggin@cyberone.com.au>
Cc: Hugh Dickins <hugh@veritas.com>, Jesse Barnes <jbarnes@sgi.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Nov 06, 2004 at 09:53:00PM +1100, Nick Piggin wrote:
> Yeah right you are. I think NOFAIL is a bug and should really not fail.

agreed.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
