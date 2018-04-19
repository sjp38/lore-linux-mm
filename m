Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3FA496B0011
	for <linux-mm@kvack.org>; Thu, 19 Apr 2018 11:10:00 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id b64so1424695pfl.13
        for <linux-mm@kvack.org>; Thu, 19 Apr 2018 08:10:00 -0700 (PDT)
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (mail-by2nam01on0128.outbound.protection.outlook.com. [104.47.34.128])
        by mx.google.com with ESMTPS id y185si3172574pgd.316.2018.04.19.08.09.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 19 Apr 2018 08:09:59 -0700 (PDT)
From: Sasha Levin <Alexander.Levin@microsoft.com>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
Date: Thu, 19 Apr 2018 15:09:56 +0000
Message-ID: <20180419150954.GC2341@sasha-vm>
References: <20180415144248.GP2341@sasha-vm>
 <20180416093058.6edca0bb@gandalf.local.home>
 <CA+55aFysLTQN8qRu=nuKttGBZzfQq=BpJBH+TMdgLJR7bgRGYg@mail.gmail.com>
 <20180416113629.2474ae74@gandalf.local.home> <20180416160200.GY2341@sasha-vm>
 <20180416121224.2138b806@gandalf.local.home> <20180416161911.GA2341@sasha-vm>
 <7d5de770-aee7-ef71-3582-5354c38fc176@mageia.org>
 <20180419135943.GC16862@kroah.com>
 <6425991f-7d7f-b1f9-ba37-3212a01ad6cf@mageia.org>
In-Reply-To: <6425991f-7d7f-b1f9-ba37-3212a01ad6cf@mageia.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <A71313D467590E4DBDC77A56E2945198@namprd21.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Backlund <tmb@mageia.org>
Cc: Greg KH <gregkh@linuxfoundation.org>, Steven Rostedt <rostedt@goodmis.org>, Linus Torvalds <torvalds@linux-foundation.org>, Petr Mladek <pmladek@suse.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>, Pavel Machek <pavel@ucw.cz>

On Thu, Apr 19, 2018 at 06:04:26PM +0300, Thomas Backlund wrote:
>Den 19.04.2018 kl. 16:59, skrev Greg KH:
>>Anyway, we are trying not to do this, but it does, and will,
>>occasionally happen.  Look, we just did that for one platform for
>>4.9.94!  And the key to all of this is good testing, which we are now
>>doing, and hopefully you are also doing as well.
>
>Yeah, but having to test stuff with known breakages is no fun, so we=20
>try to avoid that

Known breakages are easier to deal with than unknown ones :)

I think that that "bug compatability" is basically a policy on *which*
regressions you'll see vs *if* you'll see a regression.

We'll never pull in a commit that introduces a bug but doesn't fix
another one, right? So if you have to deal with a regression anyway,
might as well deal with a regression that is also seen on mainline, so
that when you upgrade your stable kernel you'll keep the same set of
regressions to deal with.=
