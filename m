Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id E49F3900086
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 16:57:07 -0400 (EDT)
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e2.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3IKbnDF031456
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 16:37:49 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3IKv5P42523312
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 16:57:05 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3IKv43B010579
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 17:57:05 -0300
Subject: Re: [PATCH 1/2] break out page allocation warning code
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <alpine.DEB.2.00.1104181321480.31186@chino.kir.corp.google.com>
References: <20110415170437.17E1AF36@kernel>
	 <alpine.DEB.2.00.1104161653220.14788@chino.kir.corp.google.com>
	 <1303139455.9615.2533.camel@nimitz>
	 <alpine.DEB.2.00.1104181321480.31186@chino.kir.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Mon, 18 Apr 2011 13:57:01 -0700
Message-ID: <1303160221.9887.301.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Nazarewicz <mina86@mina86.com>, Andrew Morton <akpm@linux-foundation.org>

On Mon, 2011-04-18 at 13:25 -0700, David Rientjes wrote:
> It shouldn't be a follow-on patch since you're introducing a new feature 
> here (vmalloc allocation failure warnings) and what I'm identifying is a 
> race in the access to current->comm.  A bug fix for a race should always 
> preceed a feature that touches the same code.

Dude.  Seriously.  Glass house!  a63d83f4

I'll go look in to it, though.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
