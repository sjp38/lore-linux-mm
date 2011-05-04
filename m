Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 9BC636B0011
	for <linux-mm@kvack.org>; Wed,  4 May 2011 16:04:41 -0400 (EDT)
Message-ID: <4DC1B151.7010300@linux.intel.com>
Date: Wed, 04 May 2011 13:04:33 -0700
From: Andi Kleen <ak@linux.intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH] Allocate memory cgroup structures in local nodes
References: <1304533058-18228-1-git-send-email-andi@firstfloor.org> <alpine.DEB.2.00.1105041213310.22426@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1105041213310.22426@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andi Kleen <andi@firstfloor.org>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Balbir Singh <balbir@in.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>


> Before that's considered, the order of the arguments to
> alloc_pages_exact_node() needs to be fixed.

Good point. I'll send another one.

This is really misleading BTW. Grumble.  Maybe it would be actually 
better to
change the prototype too.


>  The vmalloc_node() calls ensure that the nid is actually set in
>N_HIGH_MEMORY and fails otherwise (we don't fallback to using vmalloc()),
>so it looks like the failures for alloc_pages_exact_node() and
>vmalloc_node() would be different?  Why do we want to fallback for one and
>not the other?

The right order would be to try everything (alloc_pages + vmalloc)
to get it node local, before trying everything else. Right now that's
not how it's done.

-Andi



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
