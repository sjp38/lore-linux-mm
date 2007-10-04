Date: Thu, 4 Oct 2007 12:20:50 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [13/18] x86_64: Allow fallback for the stack
In-Reply-To: <200710041356.51750.ak@suse.de>
Message-ID: <Pine.LNX.4.64.0710041220010.12075@schroedinger.engr.sgi.com>
References: <20071004035935.042951211@sgi.com> <20071004040004.708466159@sgi.com>
 <200710041356.51750.ak@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, travis@sgi.com
List-ID: <linux-mm.kvack.org>

On Thu, 4 Oct 2007, Andi Kleen wrote:

> We've known for ages that it is possible. But it has been always so rare
> that it was ignored.

Well we can now address the rarity. That is the whole point of the 
patchset.

> Is there any evidence this is more common now than it used to be?

It will be more common if the stack size is increased beyond 8k.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
