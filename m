Date: Mon, 18 Feb 2002 17:48:11 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [RFC] Page table sharing
In-Reply-To: <Pine.LNX.4.33L.0202182221040.1930-100000@imladris.surriel.com>
Message-ID: <Pine.LNX.4.33.0202181746090.24597-100000@home.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Daniel Phillips <phillips@bonn-fries.net>, Hugh Dickins <hugh@veritas.com>, dmccr@us.ibm.com, Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Robert Love <rml@tech9.net>, mingo@redhat.co, Andrew Morton <akpm@zip.com.au>, manfred@colorfullife.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>


On Mon, 18 Feb 2002, Rik van Riel wrote:
>
> We'll need protection from the swapout code.

Absolutely NOT.

If the swapout code unshares or shares the PMD, that's a major bug.

The swapout code doesn't need to know one way or the other, because the
swapout code never actually touches the pmd itself, it just follows the
pointers - it doesn't ever need to worry about the pmd counts at all.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
