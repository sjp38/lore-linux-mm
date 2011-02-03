Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id B7BB08D0039
	for <linux-mm@kvack.org>; Thu,  3 Feb 2011 16:55:06 -0500 (EST)
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id p13Lt3lG010262
	for <linux-mm@kvack.org>; Thu, 3 Feb 2011 13:55:03 -0800
Received: from pzk2 (pzk2.prod.google.com [10.243.19.130])
	by wpaz24.hot.corp.google.com with ESMTP id p13LsZsP028831
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 3 Feb 2011 13:55:02 -0800
Received: by pzk2 with SMTP id 2so336974pzk.32
        for <linux-mm@kvack.org>; Thu, 03 Feb 2011 13:54:59 -0800 (PST)
Date: Thu, 3 Feb 2011 13:54:56 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC][PATCH 0/6] more detailed per-process transparent hugepage
 statistics
In-Reply-To: <20110201003357.D6F0BE0D@kernel>
Message-ID: <alpine.DEB.2.00.1102031354340.1307@chino.kir.corp.google.com>
References: <20110201003357.D6F0BE0D@kernel>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael J Wolf <mjwolf@us.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>

On Mon, 31 Jan 2011, Dave Hansen wrote:

> I'm working on some more reports that transparent huge pages and
> KSM do not play nicely together.  Basically, whenever THP's are
> present along with KSM, there is a lot of attrition over time,
> and we do not see much overall progress keeping THP's around:
> 
> 	http://sr71.net/~dave/ibm/038_System_Anonymous_Pages.png
> 
> (That's Karl Rister's graph, thanks Karl!)
> 
> However, I realized that we do not currently have a nice way to
> find out where individual THP's might be on the system.  We
> have an overall count, but no way of telling which processes or
> VMAs they might be in.
> 
> I started to implement this in the /proc/$pid/smaps code, but
> quickly realized that the lib/pagewalk.c code unconditionally
> splits THPs up.  This set reworks that code a bit and, in the
> end, gives you a per-map count of the numbers of huge pages.
> It also makes it possible for page walks to _not_ split THPs.
> 

Nice!  I'd like to start using this patchset immediately, I'm hoping 
you'll re-propose it with the fixes soon.

Thanks Dave.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
