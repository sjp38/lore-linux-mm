Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 85715900086
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 18:07:13 -0400 (EDT)
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e32.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3ELu8XH004462
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 15:56:08 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3EM78fH120294
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 16:07:08 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3EM77mE009036
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 16:07:08 -0600
Subject: Re: [PATCH 3/3] reuse __free_pages_exact() in __alloc_pages_exact()
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <alpine.DEB.2.00.1104141459510.13286@chino.kir.corp.google.com>
References: <20110414200139.ABD98551@kernel>
	 <20110414200141.09C3AA5F@kernel>
	 <alpine.DEB.2.00.1104141459510.13286@chino.kir.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Thu, 14 Apr 2011 15:07:05 -0700
Message-ID: <1302818825.16562.1094.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Timur Tabi <timur@freescale.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Michal Nazarewicz <mina86@mina86.com>

On Thu, 2011-04-14 at 15:00 -0700, David Rientjes wrote:
> On Thu, 14 Apr 2011, Dave Hansen wrote:
> > Michal Nazarewicz noticed that __alloc_pages_exact()'s
> > __free_page() loop was really close to something he was
> > using in one of his patches.   That made me realize that
> > it was actually very similar to __free_pages_exact().
> > 
> > This uses __free_pages_exact() in place of the loop
> > that we had in __alloc_pages_exact().  Since we had to
> > change the temporary variables around anyway, I gave
> > them some better names to hopefully address some other
> > review comments.
> 
> No signed-off-by?

Bah, sorry.  I'll resend the whole sucker, with sob if anybody wants.
Otherwise:

Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
