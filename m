Date: Mon, 18 Feb 2002 22:22:44 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [RFC] Page table sharing
In-Reply-To: <Pine.LNX.4.33.0202181631120.24405-100000@home.transmeta.com>
Message-ID: <Pine.LNX.4.33L.0202182221040.1930-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Daniel Phillips <phillips@bonn-fries.net>, Hugh Dickins <hugh@veritas.com>, dmccr@us.ibm.com, Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Robert Love <rml@tech9.net>, mingo@redhat.co, Andrew Morton <akpm@zip.com.au>, manfred@colorfullife.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On Mon, 18 Feb 2002, Linus Torvalds wrote:
> On Tue, 19 Feb 2002, Daniel Phillips wrote:
> >
> > Thanks, here it is again.
>
> Daniel, there's something wrong in the locking.

> Does anybody see any reason why this doesn't work totally without the
> lock?

We'll need protection from the swapout code.  It would be
embarassing if the page fault handler would run for one
mm while kswapd was holding the page_table_lock for another
mm.

I'm not sure how the page_table_share_lock is supposed
to fix that one, though.

regards,

Rik
-- 
"Linux holds advantages over the single-vendor commercial OS"
    -- Microsoft's "Competing with Linux" document

http://www.surriel.com/		http://distro.conectiva.com/


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
