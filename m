Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4AD208E005B
	for <linux-mm@kvack.org>; Sat, 29 Dec 2018 22:04:37 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id o17so22494971pgi.14
        for <linux-mm@kvack.org>; Sat, 29 Dec 2018 19:04:37 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 38sor8502470pld.67.2018.12.29.19.04.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 29 Dec 2018 19:04:36 -0800 (PST)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Date: Sun, 30 Dec 2018 12:03:41 +0900
Subject: Re: 4.14 backport request for dbdda842fe96f: "printk: Add console
 owner and waiter logic to load balance console writes"
Message-ID: <20181230030150.GA5082@tigerII.localdomain>
References: <20181109064740.GE599@jagdpanzerIV>
 <CAJmjG28Q8pEpr67LC+Un8m+Qii58FTd1esp6Zc47TnMsw50QEw@mail.gmail.com>
 <20181212052126.GF431@jagdpanzerIV>
 <CAJmjG29a7Fax5ZW5Q+W+-1xPEXVUqdrMYwoUpSwL1Msiso6gtw@mail.gmail.com>
 <20181212062841.GI431@jagdpanzerIV>
 <20181212064841.GB2746@sasha-vm>
 <20181212081034.GA32687@jagdpanzerIV>
 <20181228001651.GA514@jagdpanzerIV>
 <20181228082749.GA28315@kroah.com>
 <CAJmjG2_U3fJKsZ4FgF+ihyoNUxxQ+d79Gh-eMZJ_6pHr+Bn0CA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJmjG2_U3fJKsZ4FgF+ihyoNUxxQ+d79Gh-eMZJ_6pHr+Bn0CA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Wang <wonderfly@google.com>
Cc: Greg KH <greg@kroah.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sasha Levin <sashal@kernel.org>, Petr Mladek <pmladek@suse.com>, Steven Rostedt <rostedt@goodmis.org>, stable@vger.kernel.org, Alexander.Levin@microsoft.com, Andrew Morton <akpm@linux-foundation.org>, byungchul.park@lge.com, dave.hansen@intel.com, hannes@cmpxchg.org, jack@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Mel Gorman <mgorman@suse.de>, mhocko@kernel.org, pavel@ucw.cz, penguin-kernel@i-love.sakura.ne.jp, Peter Zijlstra <peterz@infradead.org>, tj@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, vbabka@suse.cz, Cong Wang <xiyou.wangcong@gmail.com>, Peter Feiner <pfeiner@google.com>

On (12/28/18 16:03), Daniel Wang wrote:
> Thanks. I was able to confirm that commit c7c3f05e341a9a2bd alone
> fixed the problem for me. As expected, all 16 CPUs' stacktrace was
> printed, before a final panic stack dump and a successful reboot.

Cool, thanks!

	-ss
