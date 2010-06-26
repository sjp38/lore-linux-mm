Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7537D6B01AD
	for <linux-mm@kvack.org>; Sat, 26 Jun 2010 04:11:27 -0400 (EDT)
Message-ID: <4C25B610.1050305@kernel.org>
Date: Sat, 26 Jun 2010 10:10:56 +0200
From: Tejun Heo <tj@kernel.org>
MIME-Version: 1.0
Subject: Re: [S+Q 09/16] [percpu] make allocpercpu usable during early boot
References: <20100625212026.810557229@quilx.com> <20100625212106.384650677@quilx.com>
In-Reply-To: <20100625212106.384650677@quilx.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

On 06/25/2010 11:20 PM, Christoph Lameter wrote:
> allocpercpu() may be used during early boot after the page allocator
> has been bootstrapped but when interrupts are still off. Make sure
> that we do not do GFP_KERNEL allocations if this occurs.
> 
> Cc: tj@kernel.org
> Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

Acked-by: Tejun Heo <tj@kernel.org>

Christoph, how do you wanna route these patches?  I already have the
other two patches in the percpu tree, I can push this there too, which
then you can pull into the allocator tree.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
