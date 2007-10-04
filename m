Date: Thu, 4 Oct 2007 15:39:40 -0400
From: Rik van Riel <riel@redhat.com>
Subject: Re: [13/18] x86_64: Allow fallback for the stack
Message-ID: <20071004153940.49bd5afc@bree.surriel.com>
In-Reply-To: <Pine.LNX.4.64.0710041220010.12075@schroedinger.engr.sgi.com>
References: <20071004035935.042951211@sgi.com>
	<20071004040004.708466159@sgi.com>
	<200710041356.51750.ak@suse.de>
	<Pine.LNX.4.64.0710041220010.12075@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andi Kleen <ak@suse.de>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, travis@sgi.com
List-ID: <linux-mm.kvack.org>

On Thu, 4 Oct 2007 12:20:50 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> On Thu, 4 Oct 2007, Andi Kleen wrote:
> 
> > We've known for ages that it is possible. But it has been always so
> > rare that it was ignored.
> 
> Well we can now address the rarity. That is the whole point of the 
> patchset.

Introducing complexity to fight a very rare problem with a good
fallback (refusing to fork more tasks, as well as lumpy reclaim)
somehow does not seem like a good tradeoff.
 
> > Is there any evidence this is more common now than it used to be?
> 
> It will be more common if the stack size is increased beyond 8k.

Why would we want to do such a thing?

8kB stacks are large enough...

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
