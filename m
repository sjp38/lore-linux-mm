Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id C6FC06B002B
	for <linux-mm@kvack.org>; Wed, 10 Oct 2012 05:29:49 -0400 (EDT)
Message-ID: <50753FFF.6060102@parallels.com>
Date: Wed, 10 Oct 2012 13:29:35 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [patch for-linus] memcg, kmem: fix build error when CONFIG_INET
 is disabled
References: <alpine.DEB.2.00.1210092325500.9528@chino.kir.corp.google.com> <5075383A.1000001@parallels.com> <20121010092700.GD23011@dhcp22.suse.cz>
In-Reply-To: <20121010092700.GD23011@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Randy Dunlap <rdunlap@xenotime.net>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, "David S. Miller" <davem@davemloft.net>, "Eric W.
 Biederman" <ebiederm@xmission.com>, Eric Dumazet <eric.dumazet@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Fengguang Wu <fengguang.wu@intel.com>

On 10/10/2012 01:27 PM, Michal Hocko wrote:
> On Wed 10-10-12 12:56:26, Glauber Costa wrote:
>> On 10/10/2012 10:32 AM, David Rientjes wrote:
>>> Commit e1aab161e013 ("socket: initial cgroup code.") causes a build error 
>>> when CONFIG_INET is disabled in Linus' tree:
>>>
>> unlikely that something that old would cause a build bug now, specially
>> that commit, that actually wraps things inside CONFIG_INET.
>>
>> More likely caused by the recently merged
>> "memcg-cleanup-kmem-tcp-ifdefs.patch" in -mm by mhocko (CC'd)
> 
> Strange it didn't trigger during my (and Fenguang) build testing.

Fengguang mentioned to me while testing my kmemcg tree that were a build
error occurring in the base tree, IOW, yours.

Fengguang, was that this error? Why hasn't it showed up before in the
test system?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
