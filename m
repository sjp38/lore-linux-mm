Date: Tue, 19 Feb 2002 11:02:29 +0100 (CET)
From: Roman Zippel <zippel@linux-m68k.org>
Subject: Re: [RFC] Page table sharing
In-Reply-To: <Pine.LNX.4.33.0202181822470.24671-100000@home.transmeta.com>
Message-ID: <Pine.LNX.4.33.0202191059530.22010-100000@serv>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Daniel Phillips <phillips@bonn-fries.net>, Rik van Riel <riel@conectiva.com.br>, Hugh Dickins <hugh@veritas.com>, dmccr@us.ibm.com, Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Robert Love <rml@tech9.net>, mingo@redhat.co, Andrew Morton <akpm@zip.com.au>, manfred@colorfullife.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, 18 Feb 2002, Linus Torvalds wrote:

> We can, of course, introduce a "pmd-rmap" thing, with a pointer to a
> circular list of all mm's using that pmd inside the "struct page *" of the
> pmd.

Isn't that information basically already available via
vma->vm_(pprev|next)_share?

bye, Roman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
