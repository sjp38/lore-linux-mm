Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id B63636B00EE
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 09:01:13 -0400 (EDT)
Date: Thu, 11 Aug 2011 15:01:10 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm: Switch NUMA_BUILD and COMPACTION_BUILD to new
 IS_ENABLED() syntax
Message-ID: <20110811130110.GK8023@tiehlicka.suse.cz>
References: <1312989160-737-1-git-send-email-mmarek@suse.cz>
 <20110811125133.GJ8023@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110811125133.GJ8023@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Marek <mmarek@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 11-08-11 14:51:33, Michal Hocko wrote:
> On Wed 10-08-11 17:12:40, Michal Marek wrote:
> > Introduced in 3.1-rc1, IS_ENABLED(CONFIG_NUMA) expands to a true value
> > iff CONFIG_NUMA is set. This makes it easier to grep for code that
> > depends on CONFIG_NUMA.

I have just looked closer at all available macros. Wouldn't it make more
sense to use IS_BUILTIN instead? Both symbols can be only on or off.
Not that it would make any difference in the end. I even like IS_ENABLED
naming more.
-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
