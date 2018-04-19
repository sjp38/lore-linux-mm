Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9192E6B000E
	for <linux-mm@kvack.org>; Thu, 19 Apr 2018 11:04:30 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id k76-v6so197282lfg.9
        for <linux-mm@kvack.org>; Thu, 19 Apr 2018 08:04:30 -0700 (PDT)
Received: from mx2.yrkesakademin.fi (mx2.yrkesakademin.fi. [85.134.45.195])
        by mx.google.com with ESMTPS id n14si1511499ljg.43.2018.04.19.08.04.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Apr 2018 08:04:28 -0700 (PDT)
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
References: <20180409001936.162706-15-alexander.levin@microsoft.com>
 <20180409082246.34hgp3ymkfqke3a4@pathway.suse.cz>
 <20180415144248.GP2341@sasha-vm> <20180416093058.6edca0bb@gandalf.local.home>
 <CA+55aFysLTQN8qRu=nuKttGBZzfQq=BpJBH+TMdgLJR7bgRGYg@mail.gmail.com>
 <20180416113629.2474ae74@gandalf.local.home> <20180416160200.GY2341@sasha-vm>
 <20180416121224.2138b806@gandalf.local.home> <20180416161911.GA2341@sasha-vm>
 <7d5de770-aee7-ef71-3582-5354c38fc176@mageia.org>
 <20180419135943.GC16862@kroah.com>
From: Thomas Backlund <tmb@mageia.org>
Message-ID: <6425991f-7d7f-b1f9-ba37-3212a01ad6cf@mageia.org>
Date: Thu, 19 Apr 2018 18:04:26 +0300
MIME-Version: 1.0
In-Reply-To: <20180419135943.GC16862@kroah.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <gregkh@linuxfoundation.org>, Thomas Backlund <tmb@mageia.org>
Cc: Sasha Levin <Alexander.Levin@microsoft.com>, Steven Rostedt <rostedt@goodmis.org>, Linus Torvalds <torvalds@linux-foundation.org>, Petr Mladek <pmladek@suse.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>, Pavel Machek <pavel@ucw.cz>

Den 19.04.2018 kl. 16:59, skrev Greg KH:
> On Thu, Apr 19, 2018 at 02:41:33PM +0300, Thomas Backlund wrote:
>> Den 16-04-2018 kl. 19:19, skrev Sasha Levin:
>>> On Mon, Apr 16, 2018 at 12:12:24PM -0400, Steven Rostedt wrote:
>>>> On Mon, 16 Apr 2018 16:02:03 +0000
>>>> Sasha Levin <Alexander.Levin@microsoft.com> wrote:
>>>>
>>>>> One of the things Greg is pushing strongly for is "bug compatibility":
>>>>> we want the kernel to behave the same way between mainline and stable.
>>>>> If the code is broken, it should be broken in the same way.
>>>>
>>>> Wait! What does that mean? What's the purpose of stable if it is as
>>>> broken as mainline?
>>>
>>> This just means that if there is a fix that went in mainline, and the
>>> fix is broken somehow, we'd rather take the broken fix than not.
>>>
>>> In this scenario, *something* will be broken, it's just a matter of
>>> what. We'd rather have the same thing broken between mainline and
>>> stable.
>>>
>>
>> Yeah, but _intentionally_ breaking existing setups to stay "bug compatible"
>> _is_ a _regression_ you _really_ _dont_ want in a stable
>> supported distro. Because end-users dont care about upstream breaking
>> stuff... its the distro that takes the heat for that...
>>
>> Something "already broken" is not a regression...
>>
>> As distro maintainer that means one now have to review _every_ patch that
>> carries "AUTOSEL", follow all the mail threads that comes up about it, then
>> track if it landed in -stable queue, and read every response and possible
>> objection to all patches in the -stable queue a second time around... then
>> check if it still got included in final stable point relase and then either
>> revert them in distro kernel or go track down all the follow-up fixes
>> needed...
>>
>> Just to avoid being "bug compatible with master"
> 
> I've done this "bug compatible" "breakage" more than the AUTOSEL stuff
> has in the past, so you had better also be reviewing all of my normal
> commits as well :)
> 

Yeah, I do... and same goes there ... if there is a known issue, then 
same procedure... Either revert, or try to track down fixes...


> Anyway, we are trying not to do this, but it does, and will,
> occasionally happen.  Look, we just did that for one platform for
> 4.9.94!  And the key to all of this is good testing, which we are now
> doing, and hopefully you are also doing as well.

Yeah, but having to test stuff with known breakages is no fun, so we try 
to avoid that

--
Thomas
