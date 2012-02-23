Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 31A666B004A
	for <linux-mm@kvack.org>; Thu, 23 Feb 2012 13:44:57 -0500 (EST)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC][PATCH] fix move/migrate_pages() race on task struct
References: <20120223180740.C4EC4156@kernel>
Date: Thu, 23 Feb 2012 10:45:00 -0800
In-Reply-To: <20120223180740.C4EC4156@kernel> (Dave Hansen's message of "Thu,
	23 Feb 2012 10:07:40 -0800")
Message-ID: <m2zkc9pexf.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: cl@linux.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Dave Hansen <dave@linux.vnet.ibm.com> writes:

> sys_move_pages() and sys_migrate_pages() are a pretty nice copy
> and paste job of each other.  They both take a pid, find the task
> struct, and then grab a ref on the mm.  They both also do an
> rcu_read_unlock() after they've taken the mm and then proceed to
> access 'task'.  I think this is a bug in both cases.

Can we share code?


>
> This patch takes the pid-to-task code along with the credential
> and security checks in sys_move_pages() and sys_migrate_pages()
> and consolidates them.  It now takes a task reference in
> the new function and requires the caller to drop it.  I
> believe this resolves the race.

Looks good to me.

Reviewed-by: Andi Kleen <ak@linux.intel.com>

BTW looks like we really need a better stress test for these
syscalls.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
