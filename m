Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 234E76B02A3
	for <linux-mm@kvack.org>; Wed, 14 Jul 2010 07:46:58 -0400 (EDT)
Message-ID: <4C3DA38A.7010003@kernel.org>
Date: Wed, 14 Jul 2010 13:46:18 +0200
From: Tejun Heo <tj@kernel.org>
MIME-Version: 1.0
Subject: Re: [S+Q2 00/19] SLUB with queueing (V2) beats SLAB netperf TCP_RR
References: <20100709190706.938177313@quilx.com> <20100710195621.GA13720@fancy-poultry.org> <alpine.DEB.2.00.1007121010420.14328@router.home>
In-Reply-To: <alpine.DEB.2.00.1007121010420.14328@router.home>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Heinz Diehl <htd@fancy-poultry.org>, linux-kernel@vger.kernel.org, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

Hello,

On 07/12/2010 05:11 PM, Christoph Lameter wrote:
> You need a sufficient PERCPU_DYNAMIC_EARLY_SIZE to be configured. What
> platform is this? Tejon: You suggested the BUILD_BUG_ON(). How can he
> increase the early size?

The size is determined by PERCPU_DYNAMIC_EARLY_SIZE, so bumping it up
should do it but it would probably be wiser to bump
PERCPU_DYNAMIC_RESERVE too.  PERCPU_DYNAMIC_EARLY_SIZE is currently
12k.  How high should it be?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
