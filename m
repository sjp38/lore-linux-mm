Message-ID: <481A357D.40009@cs.helsinki.fi>
Date: Fri, 02 May 2008 00:26:21 +0300
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [PATCH] slabinfo: Support printout of the number of fallbacks
References: <Pine.LNX.4.64.0804291613470.15436@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0804291613470.15436@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> [Also from your testing tree. Rediffed against current git]
> 
> Add functionality to slabinfo to print out the number of fallbacks
> that have occurred for each slab cache when the -D option is specified.
> Also widen the allocation / free field since the numbers became
> too big after a week.

Applied, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
