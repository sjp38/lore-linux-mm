Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id C78A4900086
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 18:09:53 -0400 (EDT)
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id p3EM9oW6016863
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 15:09:50 -0700
Received: from gwj17 (gwj17.prod.google.com [10.200.10.17])
	by wpaz9.hot.corp.google.com with ESMTP id p3EM9TJN018023
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 15:09:49 -0700
Received: by gwj17 with SMTP id 17so897702gwj.10
        for <linux-mm@kvack.org>; Thu, 14 Apr 2011 15:09:49 -0700 (PDT)
Date: Thu, 14 Apr 2011 15:09:46 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 3/3] reuse __free_pages_exact() in
 __alloc_pages_exact()
In-Reply-To: <1302818825.16562.1094.camel@nimitz>
Message-ID: <alpine.DEB.2.00.1104141508370.13286@chino.kir.corp.google.com>
References: <20110414200139.ABD98551@kernel> <20110414200141.09C3AA5F@kernel> <alpine.DEB.2.00.1104141459510.13286@chino.kir.corp.google.com> <1302818825.16562.1094.camel@nimitz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Timur Tabi <timur@freescale.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Michal Nazarewicz <mina86@mina86.com>

On Thu, 14 Apr 2011, Dave Hansen wrote:

> Bah, sorry.  I'll resend the whole sucker, with sob if anybody wants.
> Otherwise:
> 
> Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
> 

I think it's good to go into -mm as-is, unless anybody else has any 
objections to it.  I'd also suggest adding a

	Suggested-by: Michal Nazarewicz <mina86@mina86.com>

for this patch even though it's explained in the changelog already.

Thanks, Dave!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
