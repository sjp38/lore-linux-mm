Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 97BDC6B026E
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 12:19:18 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id o3-v6so10589319pls.11
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 09:19:18 -0700 (PDT)
Received: from NAM01-SN1-obe.outbound.protection.outlook.com (mail-sn1nam01on0108.outbound.protection.outlook.com. [104.47.32.108])
        by mx.google.com with ESMTPS id q21-v6si11640435pls.3.2018.04.16.09.19.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 16 Apr 2018 09:19:17 -0700 (PDT)
From: Sasha Levin <Alexander.Levin@microsoft.com>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
Date: Mon, 16 Apr 2018 16:19:14 +0000
Message-ID: <20180416161911.GA2341@sasha-vm>
References: <20180409001936.162706-1-alexander.levin@microsoft.com>
 <20180409001936.162706-15-alexander.levin@microsoft.com>
 <20180409082246.34hgp3ymkfqke3a4@pathway.suse.cz>
 <20180415144248.GP2341@sasha-vm> <20180416093058.6edca0bb@gandalf.local.home>
 <CA+55aFysLTQN8qRu=nuKttGBZzfQq=BpJBH+TMdgLJR7bgRGYg@mail.gmail.com>
 <20180416113629.2474ae74@gandalf.local.home> <20180416160200.GY2341@sasha-vm>
 <20180416121224.2138b806@gandalf.local.home>
In-Reply-To: <20180416121224.2138b806@gandalf.local.home>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <EB8C4AF0D5C5FB49A87D67FEF8EE2DB7@namprd21.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Petr Mladek <pmladek@suse.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>, Pavel Machek <pavel@ucw.cz>

On Mon, Apr 16, 2018 at 12:12:24PM -0400, Steven Rostedt wrote:
>On Mon, 16 Apr 2018 16:02:03 +0000
>Sasha Levin <Alexander.Levin@microsoft.com> wrote:
>
>> One of the things Greg is pushing strongly for is "bug compatibility":
>> we want the kernel to behave the same way between mainline and stable.
>> If the code is broken, it should be broken in the same way.
>
>Wait! What does that mean? What's the purpose of stable if it is as
>broken as mainline?

This just means that if there is a fix that went in mainline, and the
fix is broken somehow, we'd rather take the broken fix than not.

In this scenario, *something* will be broken, it's just a matter of
what. We'd rather have the same thing broken between mainline and
stable.=
