From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [13/18] x86_64: Allow fallback for the stack
Date: Sun, 7 Oct 2007 17:35:41 +1000
References: <20071004035935.042951211@sgi.com> <20071004153940.49bd5afc@bree.surriel.com> <Pine.LNX.4.64.0710041418100.12779@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0710041418100.12779@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200710071735.41386.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Rik van Riel <riel@redhat.com>, Andi Kleen <ak@suse.de>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, travis@sgi.com
List-ID: <linux-mm.kvack.org>

On Friday 05 October 2007 07:20, Christoph Lameter wrote:
> On Thu, 4 Oct 2007, Rik van Riel wrote:
> > > Well we can now address the rarity. That is the whole point of the
> > > patchset.
> >
> > Introducing complexity to fight a very rare problem with a good
> > fallback (refusing to fork more tasks, as well as lumpy reclaim)
> > somehow does not seem like a good tradeoff.
>
> The problem can become non-rare on special low memory machines doing wild
> swapping things though.

But only your huge systems will be using huge stacks?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
