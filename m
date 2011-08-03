Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id AD9916B0169
	for <linux-mm@kvack.org>; Wed,  3 Aug 2011 05:02:40 -0400 (EDT)
Message-ID: <4E390EBA.7060507@cn.fujitsu.com>
Date: Wed, 03 Aug 2011 17:02:50 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: kernel BUG at mm/vmscan.c:1114
References: <CAJn8CcE20-co4xNOD8c+0jMeABrc1mjmGzju3xT34QwHHHFsUA@mail.gmail.com> <CAJn8CcG-pNbg88+HLB=tRr26_R+A0RxZEWsJQg4iGe4eY2noXA@mail.gmail.com> <20110802002226.3ff0b342.akpm@linux-foundation.org> <CAJn8CcGTwhAaqghqWOYN9mGvRZDzyd9UJbYARz7NGA-7NvFg9Q@mail.gmail.com> <20110803085437.GB19099@suse.de>
In-Reply-To: <20110803085437.GB19099@suse.de>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-15
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Xiaotian Feng <xtfeng@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>

16:54, Mel Gorman wrote:
> On Wed, Aug 03, 2011 at 02:44:20PM +0800, Xiaotian Feng wrote:
>> On Tue, Aug 2, 2011 at 3:22 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
>>> On Tue, 2 Aug 2011 15:09:57 +0800 Xiaotian Feng <xtfeng@gmail.com> wrote:
>>>
>>>> __ __I'm hitting the kernel BUG at mm/vmscan.c:1114 twice, each time I
>>>> was trying to build my kernel. The photo of crash screen and my config
>>>> is attached.
>>>
>>> hm, now why has that started happening?
>>>
>>> Perhaps you could apply this debug patch, see if we can narrow it down?
>>>
>>
>> I will try it then, but it isn't very reproducible :(
>> But my system hung after some list corruption warnings... I hit the
>> corruption 4 times...
>>
> 
> That is very unexpected but if lists are being corrupted, it could
> explain the previously reported bug as that bug looked like an active
> page on an inactive list.
> 
> What was the last working kernel? Can you bisect?
> 

I just triggered the same BUG_ON() while running xfstests to test btrfs,
but I forgot to remember which test case was running when it happaned,
case 134 or around.

--
Li Zefan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
