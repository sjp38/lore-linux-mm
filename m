Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 68CED8D0039
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 23:40:01 -0500 (EST)
Date: Thu, 17 Feb 2011 20:40:36 -0800 (PST)
Message-Id: <20110217.204036.226788819.davem@davemloft.net>
Subject: Re: BUG: Bad page map in process udevd (anon_vma: (null)) in
 2.6.38-rc4
From: David Miller <davem@davemloft.net>
In-Reply-To: <AANLkTi=kEEip7UjtLqvo0Hpz8uwjVdx334hYnPsoNXis@mail.gmail.com>
References: <m1sjvm822m.fsf@fess.ebiederm.org>
	<AANLkTimzP0UNRXutkt1zJ+OGhmeg6ga87HFyMuZQmpMj@mail.gmail.com>
	<AANLkTi=kEEip7UjtLqvo0Hpz8uwjVdx334hYnPsoNXis@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: torvalds@linux-foundation.org
Cc: ebiederm@xmission.com, mingo@elte.hu, mhocko@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org, eric.dumazet@gmail.com, opurdila@ixiacom.com

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 17 Feb 2011 20:38:09 -0800

> On Thu, Feb 17, 2011 at 8:30 PM, Linus Torvalds
> <torvalds@linux-foundation.org> wrote:
>>
>> The patch from Eric Dumazet (which adds a few more cases to my patch
>> and hopefully catches them all) almost certainly fixes this rather
>> nasty memory corruption.
> 
> Oh, but you weren't cc'd on that part of the thread, since the thread
> got started from Michal Hocko's similar trouble. So you may have never
> even noticed that patch, or my "improved LIST_DEBUG" patch in the same
> thread)

I looked at Eric's (and your) patch before I wrote my reply :-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
