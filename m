Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 02F9D6B01BA
	for <linux-mm@kvack.org>; Wed,  9 Jun 2010 12:45:08 -0400 (EDT)
Message-ID: <4C0FC504.6000505@cs.helsinki.fi>
Date: Wed, 09 Jun 2010 19:44:52 +0300
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [patch 1/4] slub: replace SLAB_NODE_UNSPECIFIED with NUMA_NO_NODE
References: <alpine.DEB.2.00.1006082347440.30606@chino.kir.corp.google.com> <alpine.DEB.2.00.1006091114580.21686@router.home>
In-Reply-To: <alpine.DEB.2.00.1006091114580.21686@router.home>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> Sigh. I wish we could have avoided this. Neither name is satisfactory
> here. The meaning of -1 is unspecified. A node specification may be
> implicit here depending on the memory allocation policy. I was not sure
> how exactly to resolve the situation.
> 
> But this way work with NUMA_NO_NODE. Certainly better.
> 
> Reviewed-by: Christoph Lameter <cl@linux-foundation.org>

Applied, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
