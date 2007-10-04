Date: Thu, 4 Oct 2007 14:20:19 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [13/18] x86_64: Allow fallback for the stack
In-Reply-To: <20071004153940.49bd5afc@bree.surriel.com>
Message-ID: <Pine.LNX.4.64.0710041418100.12779@schroedinger.engr.sgi.com>
References: <20071004035935.042951211@sgi.com> <20071004040004.708466159@sgi.com>
 <200710041356.51750.ak@suse.de> <Pine.LNX.4.64.0710041220010.12075@schroedinger.engr.sgi.com>
 <20071004153940.49bd5afc@bree.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andi Kleen <ak@suse.de>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, travis@sgi.com
List-ID: <linux-mm.kvack.org>

On Thu, 4 Oct 2007, Rik van Riel wrote:

> > Well we can now address the rarity. That is the whole point of the 
> > patchset.
> 
> Introducing complexity to fight a very rare problem with a good
> fallback (refusing to fork more tasks, as well as lumpy reclaim)
> somehow does not seem like a good tradeoff.

The problem can become non-rare on special low memory machines doing wild 
swapping things though.

> > It will be more common if the stack size is increased beyond 8k.
> 
> Why would we want to do such a thing?

Because NUMA requires more stack space. In particular support for very 
large cpu configurations of 16k may require 2k cpumasks on the stack.
 
> 8kB stacks are large enough...

For many things yes. I just want to have the compile time option to 
increase it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
