From: Andi Kleen <ak@suse.de>
Subject: Re: [13/18] x86_64: Allow fallback for the stack
Date: Thu, 4 Oct 2007 14:25:43 +0200
References: <20071004035935.042951211@sgi.com> <200710041356.51750.ak@suse.de> <1191499692.22357.4.camel@twins>
In-Reply-To: <1191499692.22357.4.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200710041425.43343.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Christoph Lameter <clameter@sgi.com>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, travis@sgi.com
List-ID: <linux-mm.kvack.org>

> The order-1 allocation failures where GFP_ATOMIC, because SLUB uses !0
> order for everything.

slub is wrong then. Can it be fixed?

> Kernel stack allocation is GFP_KERNEL I presume. 

Of course.

> Also, I use 4k stacks on all my machines.

You don't have any x86-64 machines?

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
