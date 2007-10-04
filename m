From: Andi Kleen <ak@suse.de>
Subject: Re: [13/18] x86_64: Allow fallback for the stack
Date: Thu, 4 Oct 2007 13:56:51 +0200
References: <20071004035935.042951211@sgi.com> <20071004040004.708466159@sgi.com>
In-Reply-To: <20071004040004.708466159@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200710041356.51750.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, travis@sgi.com
List-ID: <linux-mm.kvack.org>

On Thursday 04 October 2007 05:59:48 Christoph Lameter wrote:
> Peter Zijlstra has recently demonstrated that we can have order 1 allocation
> failures under memory pressure with small memory configurations. The
> x86_64 stack has a size of 8k and thus requires a order 1 allocation.

We've known for ages that it is possible. But it has been always so rare
that it was ignored.

Is there any evidence this is more common now than it used to be?

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
