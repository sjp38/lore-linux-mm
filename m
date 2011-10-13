Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id B89966B002C
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 10:15:44 -0400 (EDT)
Date: Thu, 13 Oct 2011 09:15:39 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH] Reduce vm_stat cacheline contention in
 __vm_enough_memory
In-Reply-To: <1318464437.6469.16.camel@schen9-DESK>
Message-ID: <alpine.DEB.2.00.1110130914480.16230@router.home>
References: <20111012160202.GA18666@sgi.com>  <20111012120118.e948f40a.akpm@linux-foundation.org>  <CADE8fzrdMOBF1RyyEpMVi8aKcgOVKRQSKi0=c1Qvh3p6hHcXRA@mail.gmail.com> <1318464437.6469.16.camel@schen9-DESK>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dimitri Sivanich <sivanich@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ak@linux.intel.com

On Wed, 12 Oct 2011, Tim Chen wrote:

> Yeah, we have had this discussion on vm_enough_memory before.
>
> https://lkml.org/lkml/2011/1/26/473
>
> The current version of per cpu counter was not really suitable because
> the batch size is not appropriate.  I've tried to use per cpu counter
> with batch size adjusted in my attempt.  Andrew has suggested having an
> elastic batch size that's proportional to the size of the central
> counter but I haven't gotten around to try that out.

These counter are already managed as a ZVC counter. It may be easiest to
adjust the batching parameters for those to solve this issue.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
