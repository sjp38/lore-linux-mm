Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id BF9396B0003
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 15:30:05 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id b16so9949629pfi.5
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 12:30:05 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id h9si8763211pgq.464.2018.04.16.12.30.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Apr 2018 12:30:04 -0700 (PDT)
Date: Mon, 16 Apr 2018 15:30:00 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
Message-ID: <20180416153000.3fc795b6@gandalf.local.home>
In-Reply-To: <CA+55aFz0obg3SmCpa7Ff2d91CATF8p-syYjkm4s5FrR+cp5XRA@mail.gmail.com>
References: <20180416153031.GA5039@amd>
	<20180416155031.GX2341@sasha-vm>
	<20180416160608.GA7071@amd>
	<20180416122019.1c175925@gandalf.local.home>
	<20180416162757.GB2341@sasha-vm>
	<20180416163952.GA8740@amd>
	<20180416164310.GF2341@sasha-vm>
	<20180416125307.0c4f6f28@gandalf.local.home>
	<20180416170936.GI2341@sasha-vm>
	<20180416133321.40a166a4@gandalf.local.home>
	<20180416174236.GL2341@sasha-vm>
	<20180416142653.0f017647@gandalf.local.home>
	<CA+55aFzggPvS2MwFnKfXs6yHUQrbrJH7uyY4=znwetcdEXmZrw@mail.gmail.com>
	<20180416144117.5757ee70@gandalf.local.home>
	<CA+55aFyyZ7KmXbEa151JP287vypJAkxugW17YC7Q1B9=TnyHkw@mail.gmail.com>
	<CA+55aFz0obg3SmCpa7Ff2d91CATF8p-syYjkm4s5FrR+cp5XRA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Sasha Levin <Alexander.Levin@microsoft.com>, Pavel Machek <pavel@ucw.cz>, Petr Mladek <pmladek@suse.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>, Greg KH <gregkh@linuxfoundation.org>

On Mon, 16 Apr 2018 12:00:08 -0700
Linus Torvalds <torvalds@linux-foundation.org> wrote:



> > On Mon, Apr 16, 2018 at 11:52 AM, Linus Torvalds
> > <torvalds@linux-foundation.org> wrote:
> > >
> > > We're better off making *no* progress, than making "unsteady progress".
> > >
> > > Really. Seriously.  

[ me inserted: ]

> On Mon, 16 Apr 2018 3:24:29 PM, Steven Rostedt <rostedt@goodmis.org> wrote:
>
> > I'm talking about the given example of a simple memory bug that caused
> > a very subtle breakage of API, which had another trivial fix that
> > should be backported. I'm not sure that's what you were talking about.

> 
> Side note: the original impetus for this was our suspend/resume mess.
> It went on for *YEARS*, and it was absolutely chock-full of exactly
> this "I fixed the worse problem, and introduced another one".

What you are talking about here isn't what I was talking about above ;-)

-- Steve
