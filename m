Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 18A376B0028
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 12:31:13 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id w5-v6so779295plz.17
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 09:31:13 -0700 (PDT)
Received: from NAM03-CO1-obe.outbound.protection.outlook.com (mail-co1nam03on0127.outbound.protection.outlook.com. [104.47.40.127])
        by mx.google.com with ESMTPS id y72-v6si12552197plh.72.2018.04.16.09.31.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 16 Apr 2018 09:31:12 -0700 (PDT)
From: Sasha Levin <Alexander.Levin@microsoft.com>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
Date: Mon, 16 Apr 2018 16:31:09 +0000
Message-ID: <20180416163107.GC2341@sasha-vm>
References: <20180409001936.162706-15-alexander.levin@microsoft.com>
 <20180409082246.34hgp3ymkfqke3a4@pathway.suse.cz>
 <20180415144248.GP2341@sasha-vm> <20180416093058.6edca0bb@gandalf.local.home>
 <CA+55aFysLTQN8qRu=nuKttGBZzfQq=BpJBH+TMdgLJR7bgRGYg@mail.gmail.com>
 <20180416153031.GA5039@amd> <20180416155031.GX2341@sasha-vm>
 <20180416160608.GA7071@amd> <20180416161412.GZ2341@sasha-vm>
 <20180416122244.146aec48@gandalf.local.home>
In-Reply-To: <20180416122244.146aec48@gandalf.local.home>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <3D3EE2D0120A1F489CBC47A8BCC33396@namprd21.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Pavel Machek <pavel@ucw.cz>, Linus Torvalds <torvalds@linux-foundation.org>, Petr Mladek <pmladek@suse.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>

On Mon, Apr 16, 2018 at 12:22:44PM -0400, Steven Rostedt wrote:
>On Mon, 16 Apr 2018 16:14:15 +0000
>Sasha Levin <Alexander.Levin@microsoft.com> wrote:
>
>> Since the rate we're seeing now with AUTOSEL is similar to what we were
>> seeing before AUTOSEL, what's the problem it's causing?
>
>Does that mean we just doubled the rate of regressions? That's the
>problem.

No, the rate stayed the same :)

If before ~2% of stable commits were buggy, this is still the case with
AUTOSEL.

>>
>> How do you know if a bug bothers someone?
>>
>> If a user is annoyed by a LED issue, is he expected to triage the bug,
>> report it on LKML and patiently wait for the appropriate patch to be
>> backported?
>
>Yes.

I'm honestly not sure how to respond.

Let me ask my wife (who is happy using Linux as a regular desktop user)
how comfortable she would be with triaging kernel bugs...=
