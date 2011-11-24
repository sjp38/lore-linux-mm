Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 3D08B6B009B
	for <linux-mm@kvack.org>; Wed, 23 Nov 2011 21:51:55 -0500 (EST)
Message-ID: <4ECDB10E.1080007@cn.fujitsu.com>
Date: Thu, 24 Nov 2011 10:50:54 +0800
From: Miao Xie <miaox@cn.fujitsu.com>
Reply-To: miaox@cn.fujitsu.com
MIME-Version: 1.0
Subject: Re: [patch for-3.2-rc3] cpusets: stall when updating mems_allowed
 for mempolicy or disjoint nodemask
References: <alpine.DEB.2.00.1111161307020.23629@chino.kir.corp.google.com> <4EC4C603.8050704@cn.fujitsu.com> <alpine.DEB.2.00.1111171328120.15918@chino.kir.corp.google.com> <4EC62AEA.2030602@cn.fujitsu.com> <alpine.DEB.2.00.1111181545170.24487@chino.kir.corp.google.com> <4ECC5FC8.9070500@cn.fujitsu.com> <alpine.DEB.2.00.1111221902300.30008@chino.kir.corp.google.com> <4ECC7B1E.6020108@cn.fujitsu.com> <alpine.DEB.2.00.1111222210341.21009@chino.kir.corp.google.com> <4ECCA578.6020700@cn.fujitsu.com> <alpine.DEB.2.00.1111231425030.5261@chino.kir.corp.google.com> <4ECD9D43.6090202@cn.fujitsu.com> <alpine.DEB.2.00.1111231751480.9042@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1111231751480.9042@chino.kir.corp.google.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Paul Menage <paul@paulmenage.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 23 Nov 2011 17:52:08 -0800 (pst), David Rientjes wrote:
> On Thu, 24 Nov 2011, Miao Xie wrote:
> 
>> Memory compaction will see an empty nodemask and do nothing, and then
>> we may fail to get several contiguous pages.
>>
> 
> Where do we rely on a consistent nodemask for memory compaction?

Maybe I am overcautious.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
