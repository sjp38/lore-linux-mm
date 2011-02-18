Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id D2C198D0039
	for <linux-mm@kvack.org>; Fri, 18 Feb 2011 14:55:47 -0500 (EST)
Date: Fri, 18 Feb 2011 11:56:21 -0800 (PST)
Message-Id: <20110218.115621.226793798.davem@davemloft.net>
Subject: Re: BUG: Bad page map in process udevd (anon_vma: (null)) in
 2.6.38-rc4
From: David Miller <davem@davemloft.net>
In-Reply-To: <AANLkTimO=M5xG_mnDBSxPKwSOTrp3JhHVBa8=wHsiVHY@mail.gmail.com>
References: <20110218122938.GB26779@tiehlicka.suse.cz>
	<20110218162623.GD4862@tiehlicka.suse.cz>
	<AANLkTimO=M5xG_mnDBSxPKwSOTrp3JhHVBa8=wHsiVHY@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: torvalds@linux-foundation.org
Cc: mhocko@suse.cz, ebiederm@xmission.com, mingo@elte.hu, linux-mm@kvack.org, linux-kernel@vger.kernel.org, eric.dumazet@gmail.com

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 18 Feb 2011 08:39:02 -0800

> On Fri, Feb 18, 2011 at 8:26 AM, Michal Hocko <mhocko@suse.cz> wrote:
>>> Now, I will try with the 2 patches patches in this thread. I will also
>>> turn on DEBUG_LIST and DEBUG_PAGEALLOC.
>>
>> I am not able to reproduce with those 2 patches applied.
> 
> Thanks for verifying. Davem/EricD - you can add Michal's tested-by to
> the patches too.

Yep, I added Eric B.'s too, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
