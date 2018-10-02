Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 84E9C6B0006
	for <linux-mm@kvack.org>; Tue,  2 Oct 2018 04:17:00 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id ce7-v6so673803plb.22
        for <linux-mm@kvack.org>; Tue, 02 Oct 2018 01:17:00 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p75-v6sor4456250pfi.1.2018.10.02.01.16.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Oct 2018 01:16:59 -0700 (PDT)
Date: Tue, 2 Oct 2018 17:16:53 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: 4.14 backport request for dbdda842fe96f: "printk: Add console
 owner and waiter logic to load balance console writes"
Message-ID: <20181002081653.GJ598@jagdpanzerIV>
References: <20180927194601.207765-1-wonderfly@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180927194601.207765-1-wonderfly@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Wang <wonderfly@google.com>
Cc: stable@vger.kernel.org, pmladek@suse.com, Alexander.Levin@microsoft.com, akpm@linux-foundation.org, byungchul.park@lge.com, dave.hansen@intel.com, hannes@cmpxchg.org, jack@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mathieu.desnoyers@efficios.com, mgorman@suse.de, mhocko@kernel.org, pavel@ucw.cz, penguin-kernel@i-love.sakura.ne.jp, peterz@infradead.org, rostedt@goodmis.org, tj@kernel.org, torvalds@linux-foundation.org, vbabka@suse.cz, xiyou.wangcong@gmail.com, pfeiner@google.com

On (09/27/18 12:46), Daniel Wang wrote:
> Prior to this change, the combination of `softlockup_panic=1` and
> `softlockup_all_cpu_stacktrace=1` may result in a deadlock when the reboot path
> is trying to grab the console lock that is held by the stack trace printing
> path. What seems to be happening is that while there are multiple CPUs, only one
> of them is tasked to print the back trace of all CPUs. On a machine with many
> CPUs and a slow serial console (on Google Compute Engine for example), the stack
> trace printing routine hits a timeout and the reboot path kicks in. The latter
> then tries to print something else, but can't get the lock because it's still
> held by earlier printing path.

Sorry, I'm missing something here. Steven's patch deals with lockups and
I understand why you want to backport the patch set; but console output
deadlock on panic() is another thing.

You said
	"then tries to print something else, but can't get the lock
	 because it's still held by earlier printing path"

Can't get which of the locks?

	-ss
