Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniel Phillips <phillips@bonn-fries.net>
Subject: Re: [RFC] Page table sharing
Date: Tue, 19 Feb 2002 02:29:29 +0100
References: <Pine.LNX.4.33L.0202182221040.1930-100000@imladris.surriel.com>
In-Reply-To: <Pine.LNX.4.33L.0202182221040.1930-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <E16cz61-0000ya-00@starship.berlin>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>
Cc: Hugh Dickins <hugh@veritas.com>, dmccr@us.ibm.com, Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Robert Love <rml@tech9.net>, mingo@redhat.com, Andrew Morton <akpm@zip.com.au>, manfred@colorfullife.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On February 19, 2002 02:22 am, Rik van Riel wrote:
> On Mon, 18 Feb 2002, Linus Torvalds wrote:
> > On Tue, 19 Feb 2002, Daniel Phillips wrote:
> > >
> > > Thanks, here it is again.
> >
> > Daniel, there's something wrong in the locking.
> 
> > Does anybody see any reason why this doesn't work totally without the
> > lock?
> 
> We'll need protection from the swapout code.  It would be
> embarassing if the page fault handler would run for one
> mm while kswapd was holding the page_table_lock for another
> mm.
> 
> I'm not sure how the page_table_share_lock is supposed
> to fix that one, though.

It doesn't, at present.  This needs to be addressed.

-- 
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
