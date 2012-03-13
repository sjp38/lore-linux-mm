Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id C0FB56B004A
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 13:33:32 -0400 (EDT)
Message-ID: <4F5F847C.3060505@parallels.com>
Date: Tue, 13 Mar 2012 21:31:40 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 02/13] memcg: Kernel memory accounting infrastructure.
References: <1331325556-16447-1-git-send-email-ssouhlal@FreeBSD.org> <1331325556-16447-3-git-send-email-ssouhlal@FreeBSD.org> <4F5C5E54.2020408@parallels.com> <20120313152446.28b0d696.kamezawa.hiroyu@jp.fujitsu.com> <4F5F236A.1070609@parallels.com> <xr93d38g77w5.fsf@gthelen.mtv.corp.google.com>
In-Reply-To: <xr93d38g77w5.fsf@gthelen.mtv.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Suleiman Souhlal <ssouhlal@FreeBSD.org>, cgroups@vger.kernel.org, suleiman@google.com, penberg@kernel.org, cl@linux.com, yinghan@google.com, hughd@google.com, peterz@infradead.org, dan.magenheimer@oracle.com, hannes@cmpxchg.org, mgorman@suse.de, James.Bottomley@HansenPartnership.com, linux-mm@kvack.org, devel@openvz.org, linux-kernel@vger.kernel.org, rientjes@google.com

On 03/13/2012 09:00 PM, Greg Thelen wrote:
> Glauber Costa<glommer@parallels.com>  writes:
>> 2) For the kernel itself, we are mostly concerned that a malicious container may
>> pin into memory big amounts of kernel memory which is, ultimately,
>> unreclaimable. In particular, with overcommit allowed scenarios, you can fill
>> the whole physical memory (or at least a significant part) with those objects,
>> well beyond your softlimit allowance, making the creation of further containers
>> impossible.
>> With user memory, you can reclaim the cgroup back to its place. With kernel
>> memory, you can't.
>
> In overcommit situations the page allocator starts failing even though
> memcg page can charge pages.
If you overcommit mem+swap, yes. If you overcommit mem, no: reclaim 
happens first. And we don't have that option with pinned kernel memory.

Of course you *can* run your system without swap, but the whole thing 
exists exactly because there is a large enough # of ppl who wants to be 
able to overcommit their physical memory, without failing allocations.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
