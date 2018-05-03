Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id E5CF26B0005
	for <linux-mm@kvack.org>; Thu,  3 May 2018 09:31:01 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id p189so15241184pfp.1
        for <linux-mm@kvack.org>; Thu, 03 May 2018 06:31:01 -0700 (PDT)
Received: from NAM02-CY1-obe.outbound.protection.outlook.com (mail-cys01nam02on0132.outbound.protection.outlook.com. [104.47.37.132])
        by mx.google.com with ESMTPS id a8-v6si13460060ple.222.2018.05.03.06.31.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 03 May 2018 06:31:00 -0700 (PDT)
From: Sasha Levin <Alexander.Levin@microsoft.com>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
Date: Thu, 3 May 2018 13:30:57 +0000
Message-ID: <20180503133053.GI18390@sasha-vm>
References: 
 <CA+55aFysLTQN8qRu=nuKttGBZzfQq=BpJBH+TMdgLJR7bgRGYg@mail.gmail.com>
 <20180416113629.2474ae74@gandalf.local.home> <20180416160200.GY2341@sasha-vm>
 <20180416121224.2138b806@gandalf.local.home> <20180416161911.GA2341@sasha-vm>
 <20180416123019.4d235374@gandalf.local.home> <20180416163754.GD2341@sasha-vm>
 <20180416170604.GC11034@amd> <20180416172327.GK2341@sasha-vm>
 <20180503093214.GB32180@amd>
In-Reply-To: <20180503093214.GB32180@amd>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <752880930140F24481B3BCAF2318E19D@namprd21.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: Steven Rostedt <rostedt@goodmis.org>, Linus Torvalds <torvalds@linux-foundation.org>, Petr Mladek <pmladek@suse.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>

On Thu, May 03, 2018 at 11:32:15AM +0200, Pavel Machek wrote:
>Hi!
>
>> >- It must be obviously correct and tested.
>> >
>> >If it introduces new bug, it is not correct, and certainly not
>> >obviously correct.
>>
>> As you might have noticed, we don't strictly follow the rules.
>
>Yes, I noticed. And what I'm saying is that perhaps you should follow
>the rules more strictly.

Again, this was stated many times by Greg and others, the rules are not
there to be strictly followed.

>> Take a look at the whole PTI story as an example. It's way more than 100
>> lines, it's not obviously corrent, it fixed more than 1 thing, and so
>> on, and yet it went in -stable!
>>
>> Would you argue we shouldn't have backported PTI to -stable?
>
>Actually, I was surprised with PTI going to stable. That was clearly
>against the rules. Maybe the security bug was ugly enough to warrant
>that.
>
>But please don't use it as an argument for applying any random
>patches...

How about this: if a -stable maintainer has concerns with how I follow
the -stable rules, he's more than welcome to reject my patches. Sounds
like a plan?=
