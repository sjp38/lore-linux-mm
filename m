Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 2A39B6B002B
	for <linux-mm@kvack.org>; Wed, 10 Oct 2012 04:56:44 -0400 (EDT)
Message-ID: <5075383A.1000001@parallels.com>
Date: Wed, 10 Oct 2012 12:56:26 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [patch for-linus] memcg, kmem: fix build error when CONFIG_INET
 is disabled
References: <alpine.DEB.2.00.1210092325500.9528@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1210092325500.9528@chino.kir.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Randy Dunlap <rdunlap@xenotime.net>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, "David S. Miller" <davem@davemloft.net>, "Eric W.
 Biederman" <ebiederm@xmission.com>, Eric Dumazet <eric.dumazet@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>

On 10/10/2012 10:32 AM, David Rientjes wrote:
> Commit e1aab161e013 ("socket: initial cgroup code.") causes a build error 
> when CONFIG_INET is disabled in Linus' tree:
> 
unlikely that something that old would cause a build bug now, specially
that commit, that actually wraps things inside CONFIG_INET.

More likely caused by the recently merged
"memcg-cleanup-kmem-tcp-ifdefs.patch" in -mm by mhocko (CC'd)

As a matter of fact, I just tested, and it indeed start failing after
that patch.

Michal, since it is just a cleanup patch, I'd prefer just reverting if
you are okay with it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
