Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 4000B6B004D
	for <linux-mm@kvack.org>; Tue,  9 Feb 2010 22:10:20 -0500 (EST)
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id o1A3AF59005589
	for <linux-mm@kvack.org>; Wed, 10 Feb 2010 03:10:15 GMT
Received: from pxi36 (pxi36.prod.google.com [10.243.27.36])
	by wpaz33.hot.corp.google.com with ESMTP id o1A3ADMI004262
	for <linux-mm@kvack.org>; Tue, 9 Feb 2010 19:10:13 -0800
Received: by pxi36 with SMTP id 36so7781127pxi.26
        for <linux-mm@kvack.org>; Tue, 09 Feb 2010 19:10:12 -0800 (PST)
Date: Tue, 9 Feb 2010 19:10:10 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: Improving OOM killer
In-Reply-To: <201002050835.30550.oliver@neukum.org>
Message-ID: <alpine.DEB.2.00.1002091906020.31159@chino.kir.corp.google.com>
References: <201002012302.37380.l.lunak@suse.cz> <alpine.LNX.2.00.1002041044080.15395@pobox.suse.cz> <alpine.DEB.2.00.1002041335140.6071@chino.kir.corp.google.com> <201002050835.30550.oliver@neukum.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Oliver Neukum <oliver@neukum.org>
Cc: Jiri Kosina <jkosina@suse.cz>, Lubos Lunak <l.lunak@suse.cz>, Balbir Singh <balbir@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Fri, 5 Feb 2010, Oliver Neukum wrote:

> > That's what we're trying to do, we can look at the shear number of 
> > children that the parent has forked and check for it to be over a certain 
> > "forkbombing threshold" (which, yes, can be tuned from userspace), the 
> > uptime of those children, their resident set size, etc., to attempt to 
> > find a sane heuristic that penalizes them.
> 
> Wouldn't it be saner to have a selection by user, so that users that
> are over the overcommit limit are targeted?
> 

It's rather unnecessary for the forkbomb case because then it would 
unfairly penalize any user that runs lots of tasks.  The forkbomb handling 
code is really to prevent either user error, bugs in the application, or 
maliciousness.  The goal isn't necessarily to kill anything that forks an 
egregious amount of tasks (which is why we always prefer a child with a 
seperate address space than a parent, anyway) but rather to try to make 
sure the system is still usable and recoverable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
