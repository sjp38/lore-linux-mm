Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 0D8226B0011
	for <linux-mm@kvack.org>; Wed,  4 May 2011 16:18:04 -0400 (EDT)
Message-ID: <4DC1B47B.1010209@linux.intel.com>
Date: Wed, 04 May 2011 13:18:03 -0700
From: Andi Kleen <ak@linux.intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH] Allocate memory cgroup structures in local nodes
References: <1304533058-18228-1-git-send-email-andi@firstfloor.org> <alpine.DEB.2.00.1105041213310.22426@chino.kir.corp.google.com> <4DC1B151.7010300@linux.intel.com> <alpine.DEB.2.00.1105041309001.24395@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1105041309001.24395@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andi Kleen <andi@firstfloor.org>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Balbir Singh <balbir@in.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>


> Completely agreed, I think that's how it should be patched instead of only
> touching the alloc_pages() allocation; we care much more about local node
> than whether we're using vmalloc.

Right now the problem is you end up in node 0 always and then run out of 
memory
later on it on a large system. That's the problem I'm trying to solve ASAP

The rest is much less important.


-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
