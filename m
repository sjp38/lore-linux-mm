Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 131DE6B005C
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 11:54:28 -0400 (EDT)
Date: Tue, 26 Jun 2012 17:54:22 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/2] fix bad behavior in use_hierarchy file
Message-ID: <20120626155422.GD27816@cmpxchg.org>
References: <1340725634-9017-1-git-send-email-glommer@parallels.com>
 <1340725634-9017-2-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1340725634-9017-2-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Dhaval Giani <dhaval.giani@gmail.com>

On Tue, Jun 26, 2012 at 07:47:13PM +0400, Glauber Costa wrote:
> I have an application that does the following:
> 
> * copy the state of all controllers attached to a hierarchy
> * replicate it as a child of the current level.
> 
> I would expect writes to the files to mostly succeed, since they
> are inheriting sane values from parents.
> 
> But that is not the case for use_hierarchy. If it is set to 0, we
> succeed ok. If we're set to 1, the value of the file is automatically
> set to 1 in the children, but if userspace tries to write the
> very same 1, it will fail. That same situation happens if we
> set use_hierarchy, create a child, and then try to write 1 again.
> 
> Now, there is no reason whatsoever for failing to write a value
> that is already there. It doesn't even match the comments, that
> states:
> 
>  /* If parent's use_hierarchy is set, we can't make any modifications
>   * in the child subtrees...
> 
> since we are not changing anything.
> 
> The following patch tests the new value against the one we're storing,
> and automatically return 0 if we're not proposing a change.
> 
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> CC: Dhaval Giani <dhaval.giani@gmail.com>
> CC: Michal Hocko <mhocko@suse.cz>
> CC: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> CC: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
