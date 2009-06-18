Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 86CF06B005A
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 22:03:09 -0400 (EDT)
Message-ID: <4A39A054.1040603@kernel.org>
Date: Thu, 18 Jun 2009 11:03:00 +0900
From: Tejun Heo <tj@kernel.org>
MIME-Version: 1.0
Subject: Re: [this_cpu_xx V2 04/19] Use this_cpu operations for NFS statistics
References: <20090617203337.399182817@gentwo.org> <20090617203443.566183743@gentwo.org>
In-Reply-To: <20090617203443.566183743@gentwo.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: cl@linux-foundation.org
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Trond Myklebust <trond.myklebust@fys.uio.no>, mingo@elte.hu, rusty@rustcorp.com.au, davem@davemloft.net
List-ID: <linux-mm.kvack.org>

cl@linux-foundation.org wrote:
> Simplify NFS statistics and allow the use of optimized
> arch instructions.
> 
> CC: Trond Myklebust <trond.myklebust@fys.uio.no>
> Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

For 04-09

Acked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
