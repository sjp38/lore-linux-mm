Subject: Re: [patch 1/3] add the fsblock layer
References: <20070624014528.GA17609@wotan.suse.de>
	<20070624014613.GB17609@wotan.suse.de>
From: Andi Kleen <andi@firstfloor.org>
Date: 24 Jun 2007 17:28:39 +0200
In-Reply-To: <20070624014613.GB17609@wotan.suse.de>
Message-ID: <p73fy4h5q3c.fsf@bingen.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Nick Piggin <npiggin@suse.de> writes:


[haven't read everything, just commenting on something that caught my eye]

> +struct fsblock {
> +	atomic_t	count;
> +	union {
> +		struct {
> +			unsigned long	flags; /* XXX: flags could be int for better packing */

int is not supported by many architectures, but works on x86 at least.

Hmm, could define a macro DECLARE_ATOMIC_BITMAP(maxbit) that expands to the smallest
possible type for each architecture. And a couple of ugly casts for set_bit et.al.
but those could be also hidden in macros. Should be relatively easy to do.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
