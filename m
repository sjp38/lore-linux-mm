Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id C78B96B0022
	for <linux-mm@kvack.org>; Wed,  4 May 2011 17:43:00 -0400 (EDT)
Date: Wed, 4 May 2011 23:42:56 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] Allocate memory cgroup structures in local nodes v2
Message-ID: <20110504214256.GA2925@one.firstfloor.org>
References: <1304540783-8247-1-git-send-email-andi@firstfloor.org> <20110504213850.GA16685@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110504213850.GA16685@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andi Kleen <andi@firstfloor.org>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andi Kleen <ak@linux.intel.com>, rientjes@google.com, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Balbir Singh <balbir@in.ibm.com>

> I don't think any of those mistakes even triggers a compiler warning.
> Wow.  This API is so thoroughly fscked beyond belief that I think the
> only way to top this is to have one of the functions invert the bits
> of its return value depending on the parity of the uptime counter.

Yes I must agree. Oops. Ok I'm retracting the patch for now
and do more testing (i think it just hit the fallback)

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
