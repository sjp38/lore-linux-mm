Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 56CA76B002C
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 15:29:53 -0500 (EST)
Date: Thu, 8 Mar 2012 12:29:51 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] mm, memcg: do not allow tasks to be attached with zero
 limit
Message-Id: <20120308122951.2988ec4e.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.1203071914150.15244@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1203071914150.15244@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, cgroups@vger.kernel.org, linux-mm@kvack.org

On Wed, 7 Mar 2012 19:14:49 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> This patch prevents tasks from being attached to a memcg if there is a
> hard limit of zero.

We're talking about the memcg's limit_in_bytes here, yes?

> Additionally, the hard limit may not be changed to
> zero if there are tasks attached.

hm, well...  why?  That would be user error, wouldn't it?  What is
special about limit_in_bytes=0?  The memcg will also be unviable if
limit_in_bytes=1, but we permit that.

IOW, confused.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
