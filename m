Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5AA3D6B0007
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 12:39:26 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id t3so551420pgc.21
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 09:39:26 -0700 (PDT)
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (mail-by2nam01on0138.outbound.protection.outlook.com. [104.47.34.138])
        by mx.google.com with ESMTPS id x10-v6si6044191plm.5.2018.04.16.09.39.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 16 Apr 2018 09:39:25 -0700 (PDT)
From: Sasha Levin <Alexander.Levin@microsoft.com>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
Date: Mon, 16 Apr 2018 16:39:20 +0000
Message-ID: <20180416163917.GE2341@sasha-vm>
References: <20180409001936.162706-15-alexander.levin@microsoft.com>
 <20180409082246.34hgp3ymkfqke3a4@pathway.suse.cz>
 <20180415144248.GP2341@sasha-vm> <20180416093058.6edca0bb@gandalf.local.home>
 <CA+55aFysLTQN8qRu=nuKttGBZzfQq=BpJBH+TMdgLJR7bgRGYg@mail.gmail.com>
 <20180416153031.GA5039@amd> <20180416155031.GX2341@sasha-vm>
 <20180416160608.GA7071@amd> <20180416161412.GZ2341@sasha-vm>
 <20180416162850.GA7553@amd>
In-Reply-To: <20180416162850.GA7553@amd>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <72CFA7D0500218408DD130DE38BEB7B7@namprd21.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>, Petr Mladek <pmladek@suse.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>

On Mon, Apr 16, 2018 at 06:28:50PM +0200, Pavel Machek wrote:
>
>> >> Is there a reason not to take LED fixes if they fix a bug and don't
>> >> cause a regression? Sure, we can draw some arbitrary line, maybe
>> >> designate some subsystems that are more "important" than others, but
>> >> what's the point?
>> >
>> >There's a tradeoff.
>> >
>> >You want to fix serious bugs in stable, and you really don't want
>> >regressions in stable. And ... stable not having 1000s of patches
>> >would be nice, too.
>>
>> I don't think we should use a number cap here, but rather look at the
>> regression rate: how many patches broke something?
>>
>> Since the rate we're seeing now with AUTOSEL is similar to what we were
>> seeing before AUTOSEL, what's the problem it's causing?
>
>Regression rate should not be the only criteria.
>
>More patches mean bigger chance customer's patches will have a
>conflict with something in -stable, for example.

Out of tree patches can't be a consideration here. There are no
guarantees for out of tree code, ever.
