Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id CE0A26B0027
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 12:45:23 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id m134-v6so9738283itb.9
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 09:45:23 -0700 (PDT)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0130.outbound.protection.outlook.com. [104.47.33.130])
        by mx.google.com with ESMTPS id f65si8231623ioa.124.2018.04.16.09.45.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 16 Apr 2018 09:45:22 -0700 (PDT)
From: Sasha Levin <Alexander.Levin@microsoft.com>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
Date: Mon, 16 Apr 2018 16:45:16 +0000
Message-ID: <20180416164514.GG2341@sasha-vm>
References: <20180415144248.GP2341@sasha-vm>
 <20180416093058.6edca0bb@gandalf.local.home>
 <CA+55aFysLTQN8qRu=nuKttGBZzfQq=BpJBH+TMdgLJR7bgRGYg@mail.gmail.com>
 <20180416153031.GA5039@amd> <20180416155031.GX2341@sasha-vm>
 <20180416160608.GA7071@amd> <20180416161412.GZ2341@sasha-vm>
 <20180416162850.GA7553@amd> <20180416163917.GE2341@sasha-vm>
 <20180416164230.GA9807@amd>
In-Reply-To: <20180416164230.GA9807@amd>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <F369767A41F444469453033E14F222E8@namprd21.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>, Petr Mladek <pmladek@suse.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>

On Mon, Apr 16, 2018 at 06:42:30PM +0200, Pavel Machek wrote:
>On Mon 2018-04-16 16:39:20, Sasha Levin wrote:
>> On Mon, Apr 16, 2018 at 06:28:50PM +0200, Pavel Machek wrote:
>> >
>> >> >> Is there a reason not to take LED fixes if they fix a bug and don'=
t
>> >> >> cause a regression? Sure, we can draw some arbitrary line, maybe
>> >> >> designate some subsystems that are more "important" than others, b=
ut
>> >> >> what's the point?
>> >> >
>> >> >There's a tradeoff.
>> >> >
>> >> >You want to fix serious bugs in stable, and you really don't want
>> >> >regressions in stable. And ... stable not having 1000s of patches
>> >> >would be nice, too.
>> >>
>> >> I don't think we should use a number cap here, but rather look at the
>> >> regression rate: how many patches broke something?
>> >>
>> >> Since the rate we're seeing now with AUTOSEL is similar to what we we=
re
>> >> seeing before AUTOSEL, what's the problem it's causing?
>> >
>> >Regression rate should not be the only criteria.
>> >
>> >More patches mean bigger chance customer's patches will have a
>> >conflict with something in -stable, for example.
>>
>> Out of tree patches can't be a consideration here. There are no
>> guarantees for out of tree code, ever.
>
>Out of tree code is not consideration for mainline, agreed. Stable
>should be different.

This is a discussion we could have with in right forum, but FYI stable
doesn't even guarantee KABI compatibility between minor versions at this
point.
