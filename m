Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 9D5816B007E
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 13:04:22 -0400 (EDT)
Received: by ggki24 with SMTP id i24so125571ggk.2
        for <linux-mm@kvack.org>; Tue, 13 Mar 2012 10:04:21 -0700 (PDT)
From: Greg Thelen <gthelen@google.com>
Subject: Re: [PATCH v2 02/13] memcg: Kernel memory accounting infrastructure.
References: <1331325556-16447-1-git-send-email-ssouhlal@FreeBSD.org>
	<1331325556-16447-3-git-send-email-ssouhlal@FreeBSD.org>
	<4F5C5E54.2020408@parallels.com>
	<20120313152446.28b0d696.kamezawa.hiroyu@jp.fujitsu.com>
	<4F5F236A.1070609@parallels.com>
Date: Tue, 13 Mar 2012 10:00:58 -0700
In-Reply-To: <4F5F236A.1070609@parallels.com> (Glauber Costa's message of
	"Tue, 13 Mar 2012 14:37:30 +0400")
Message-ID: <xr93d38g77w5.fsf@gthelen.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Suleiman Souhlal <ssouhlal@FreeBSD.org>, cgroups@vger.kernel.org, suleiman@google.com, penberg@kernel.org, cl@linux.com, yinghan@google.com, hughd@google.com, peterz@infradead.org, dan.magenheimer@oracle.com, hannes@cmpxchg.org, mgorman@suse.de, James.Bottomley@HansenPartnership.com, linux-mm@kvack.org, devel@openvz.org, linux-kernel@vger.kernel.org, rientjes@google.com

Glauber Costa <glommer@parallels.com> writes:
> 2) For the kernel itself, we are mostly concerned that a malicious container may
> pin into memory big amounts of kernel memory which is, ultimately,
> unreclaimable. In particular, with overcommit allowed scenarios, you can fill
> the whole physical memory (or at least a significant part) with those objects,
> well beyond your softlimit allowance, making the creation of further containers
> impossible.
> With user memory, you can reclaim the cgroup back to its place. With kernel
> memory, you can't.

In overcommit situations the page allocator starts failing even though
memcg page can charge pages.  When page allocations fail the oom killer
plays a role.  Page allocations can fail even without malicious usage of
kernel memory (e.g. lots of mlock or anon without swap can fill a
machine).  I assume that the kernel memory pinned the malicious
containers will be freed or at least become reclaimable once the
processes in malicious containers are killed (oom or otherwise).  We
have been making use of the oom killer to save a system from
irreconcilable overcommit situations.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
