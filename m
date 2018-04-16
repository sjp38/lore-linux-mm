Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id B1A946B0009
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 14:35:48 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 203so9877276pfz.19
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 11:35:48 -0700 (PDT)
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (mail-by2nam01on0108.outbound.protection.outlook.com. [104.47.34.108])
        by mx.google.com with ESMTPS id a6-v6si10938080plz.211.2018.04.16.11.35.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 16 Apr 2018 11:35:47 -0700 (PDT)
From: Sasha Levin <Alexander.Levin@microsoft.com>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
Date: Mon, 16 Apr 2018 18:35:44 +0000
Message-ID: <20180416183542.GN2341@sasha-vm>
References: <20180416160608.GA7071@amd>
 <20180416122019.1c175925@gandalf.local.home> <20180416162757.GB2341@sasha-vm>
 <20180416163952.GA8740@amd> <20180416164310.GF2341@sasha-vm>
 <20180416125307.0c4f6f28@gandalf.local.home> <20180416170936.GI2341@sasha-vm>
 <20180416133321.40a166a4@gandalf.local.home> <20180416174236.GL2341@sasha-vm>
 <20180416142653.0f017647@gandalf.local.home>
In-Reply-To: <20180416142653.0f017647@gandalf.local.home>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <B6F4768DA2D9B7409910EC330F4EC0F4@namprd21.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Pavel Machek <pavel@ucw.cz>, Linus Torvalds <torvalds@linux-foundation.org>, Petr Mladek <pmladek@suse.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>, Greg KH <gregkh@linuxfoundation.org>

On Mon, Apr 16, 2018 at 02:26:53PM -0400, Steven Rostedt wrote:
>On Mon, 16 Apr 2018 17:42:38 +0000
>Sasha Levin <Alexander.Levin@microsoft.com> wrote:
>> Also note that all of these patches were tagged for stable and actually
>> ended up in at least one tree.
>>
>> This is why I'm basing a lot of my decision making on the rejection rate=
.
>> If the AUTOSEL process does the job well enough as the "regular"
>> process did before, why push it back?
>
>Because I think we are adding too many patches to stable. And
>automating it may just make things worse. Your examples above back my
>argument more than they refute it. If people can't determine what is
>"obviously correct" how is automation going to do any better?

I don't understand that statament, it sounds illogical to me.

If I were to tell you that I have a crack team of 10 kernel hackers who
dig through all mainline commits to find commits that should be
backported to stable, and they do it with less mistakes than
authors/maintainers make when they tag their own commits, would I get the
same level of objection?

On the correctness side, I have another effort to improve the quality of
testing -stable commits get, but this is somewhat unrelated to the whole
automatic selection process.=
