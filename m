Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 283476B004A
	for <linux-mm@kvack.org>; Fri, 24 Feb 2012 12:08:44 -0500 (EST)
Date: Fri, 24 Feb 2012 11:08:41 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC][PATCH] fix move/migrate_pages() race on task struct
In-Reply-To: <alpine.DEB.2.00.1202241053220.3726@router.home>
Message-ID: <alpine.DEB.2.00.1202241105280.3726@router.home>
References: <20120223180740.C4EC4156@kernel> <alpine.DEB.2.00.1202231240590.9878@router.home> <4F468F09.5050200@linux.vnet.ibm.com> <alpine.DEB.2.00.1202231334290.10914@router.home> <4F469BC7.50705@linux.vnet.ibm.com> <alpine.DEB.2.00.1202231536240.13554@router.home>
 <m1ehtkapn9.fsf@fess.ebiederm.org> <alpine.DEB.2.00.1202240859340.2621@router.home> <4F47BF56.6010602@linux.vnet.ibm.com> <alpine.DEB.2.00.1202241053220.3726@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Oh and another thing. There are certain functions that are now called
under rcu read lock()

	security_task_movememory

and

	cpuset_mems_allowed


cpuset_mems_allowed takes a mutex. Hmmm... Under rcu?

security_task_movememory does some kind of security hook.


Is that all safe? If not then we need to take a refcount on the task
struct after all.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
