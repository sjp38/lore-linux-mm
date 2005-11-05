Subject: Re: [PATCH]: Clean up of __alloc_pages
References: <20051028183326.A28611@unix-os.sc.intel.com>
	<20051029171630.04a69660.pj@sgi.com>
From: Andi Kleen <ak@suse.de>
Date: 05 Nov 2005 18:09:14 +0100
In-Reply-To: <20051029171630.04a69660.pj@sgi.com>
Message-ID: <p73oe4z2f9h.fsf@verdi.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: akpm@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Paul Jackson <pj@sgi.com> writes:


Regarding cpumemset and alloc_pages. I recently rechecked
the cpumemset hooks in there and I must say they turned out
to be quite worse

In hindsight it would have been better to use the "generate
zonelists for all possible nodes" approach you originally had
and which I rejected (sorry) 

That would make the code much cleaner and faster.
Maybe it's not too late to switch for that?

If not then the fast path definitely needs to be tuned a bit.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
