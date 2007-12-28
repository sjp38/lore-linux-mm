From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH 05/10] x86_64: Use generic percpu
Date: Fri, 28 Dec 2007 13:54:51 +0100
References: <20071228001046.854702000@sgi.com> <20071228001047.556634000@sgi.com>
In-Reply-To: <20071228001047.556634000@sgi.com>
MIME-Version: 1.0
Content-Disposition: inline
Message-Id: <200712281354.52453.ak@suse.de>
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: travis@sgi.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>, tglx@linutronix.de, mingo@redhat.com
List-ID: <linux-mm.kvack.org>

On Friday 28 December 2007 01:10:51 travis@sgi.com wrote:
> x86_64 provides an optimized way to determine the local per cpu area
> offset through the pda and determines the base by accessing a remote
> pda.

And? The rationale for this patch seems to be incomplete.

As far as I can figure out you're replacing an optimized percpu 
implementation which a dumber generic one. Which needs
at least some description why.

If the generic one is now as good or better than the 
specific one that might be ok, but that should be somewhere
in the description.

Also for such changes .text size comparisons before/after
are a good idea.

-Andi
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
