Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id A6CA06B0022
	for <linux-mm@kvack.org>; Fri,  6 May 2011 13:07:01 -0400 (EDT)
Date: Fri, 6 May 2011 19:06:59 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 2/2] Allocate memory cgroup structures in local nodes v3
Message-ID: <20110506170659.GH11636@one.firstfloor.org>
References: <1304624762-27960-1-git-send-email-andi@firstfloor.org> <1304624762-27960-2-git-send-email-andi@firstfloor.org> <20110506084939.GD32495@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110506084939.GD32495@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, akpm@linux-foundation.org, Andi Kleen <ak@linux.intel.com>, rientjes@google.com, Dave Hansen <dave@linux.vnet.ibm.com>, Balbir Singh <balbir@in.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>

> What is this printk for? Other than that the change looks good to me.

Leftover debugging code. I'll remove it.

Thanks.
-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
