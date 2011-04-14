Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 386B2900086
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 18:00:37 -0400 (EDT)
Received: from kpbe20.cbf.corp.google.com (kpbe20.cbf.corp.google.com [172.25.105.84])
	by smtp-out.google.com with ESMTP id p3EM0H5G013527
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 15:00:18 -0700
Received: from gwj16 (gwj16.prod.google.com [10.200.10.16])
	by kpbe20.cbf.corp.google.com with ESMTP id p3EM0BnC003138
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 15:00:11 -0700
Received: by gwj16 with SMTP id 16so2573539gwj.37
        for <linux-mm@kvack.org>; Thu, 14 Apr 2011 15:00:11 -0700 (PDT)
Date: Thu, 14 Apr 2011 15:00:07 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 3/3] reuse __free_pages_exact() in
 __alloc_pages_exact()
In-Reply-To: <20110414200141.09C3AA5F@kernel>
Message-ID: <alpine.DEB.2.00.1104141459510.13286@chino.kir.corp.google.com>
References: <20110414200139.ABD98551@kernel> <20110414200141.09C3AA5F@kernel>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Timur Tabi <timur@freescale.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Michal Nazarewicz <mina86@mina86.com>

On Thu, 14 Apr 2011, Dave Hansen wrote:

> 
> Michal Nazarewicz noticed that __alloc_pages_exact()'s
> __free_page() loop was really close to something he was
> using in one of his patches.   That made me realize that
> it was actually very similar to __free_pages_exact().
> 
> This uses __free_pages_exact() in place of the loop
> that we had in __alloc_pages_exact().  Since we had to
> change the temporary variables around anyway, I gave
> them some better names to hopefully address some other
> review comments.
> 

No signed-off-by?

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
