Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id E68A06B0082
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 10:55:36 -0400 (EDT)
Date: Wed, 3 Jun 2009 17:02:42 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [patch][v2] swap: virtual swap readahead
Message-ID: <20090603150242.GB1065@one.firstfloor.org>
References: <20090602223738.GA15475@cmpxchg.org> <20090602233457.GY1065@one.firstfloor.org> <20090603132751.GA1813@cmpxchg.org> <4A268DF8.6000701@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4A268DF8.6000701@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> I'm not too worried about not walking the page tables,
> because swap is an extreme slow path anyway.

it was more about taking less locks and doing less mappings.
Especially highmem pte mappings can be quite expensive, because
they have to flush parts of the TLB.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
