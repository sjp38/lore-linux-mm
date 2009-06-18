Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id C72AE6B005A
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 21:54:02 -0400 (EDT)
Message-ID: <4A399E9B.3070701@kernel.org>
Date: Thu, 18 Jun 2009 10:55:39 +0900
From: Tejun Heo <tj@kernel.org>
MIME-Version: 1.0
Subject: Re: [this_cpu_xx V2 03/19] Use this_cpu operations for SNMP statistics
References: <20090617203337.399182817@gentwo.org> <20090617203443.371256548@gentwo.org>
In-Reply-To: <20090617203443.371256548@gentwo.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: cl@linux-foundation.org
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, mingo@elte.hu, rusty@rustcorp.com.au, davem@davemloft.net
List-ID: <linux-mm.kvack.org>

cl@linux-foundation.org wrote:
> SNMP statistic macros can be signficantly simplified.
> This will also reduce code size if the arch supports these operations
> in harware.
> 
> Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

Acked-by: Tejun Heo <tj@kernel.org>

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
