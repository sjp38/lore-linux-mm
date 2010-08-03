Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id D43846008E4
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 00:28:29 -0400 (EDT)
Message-ID: <4C579BFA.40302@cs.helsinki.fi>
Date: Tue, 03 Aug 2010 07:32:58 +0300
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [S+Q2 07/19] slub: Allow removal of slab caches during boot
References: <20100709190706.938177313@quilx.com>  <20100709190853.770833931@quilx.com>  <alpine.DEB.2.00.1007141647340.29110@chino.kir.corp.google.com> <1279498030.10390.1760.camel@pasglop> <alpine.DEB.2.00.1007191058220.29361@router.home> <4C53EFBA.4090900@cs.helsinki.fi> <alpine.DEB.2.00.1008021036210.18455@router.home>
In-Reply-To: <alpine.DEB.2.00.1008021036210.18455@router.home>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Roland Dreier <rdreier@cisco.com>, linux-kernel@vger.kernel.org, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Sat, 31 Jul 2010, Pekka Enberg wrote:
> 
>> Christoph, Ben, should I queue this up for 2.6.36?
> 
> Yes.

Applied, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
