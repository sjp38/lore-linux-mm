Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id B0AAA6B0003
	for <linux-mm@kvack.org>; Mon,  1 Oct 2018 16:23:59 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id y15-v6so35530eds.14
        for <linux-mm@kvack.org>; Mon, 01 Oct 2018 13:23:59 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b1-v6si5109557edy.356.2018.10.01.13.23.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Oct 2018 13:23:58 -0700 (PDT)
Subject: Re: 4.14 backport request for dbdda842fe96f: "printk: Add console
 owner and waiter logic to load balance console writes"
References: <20180927194601.207765-1-wonderfly@google.com>
 <20181001152324.72a20bea@gandalf.local.home> <20181001201309.GA9835@amd>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <85b9ab27-ec57-647b-4c92-1afb9b595a2a@suse.cz>
Date: Mon, 1 Oct 2018 22:21:14 +0200
MIME-Version: 1.0
In-Reply-To: <20181001201309.GA9835@amd>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>, Steven Rostedt <rostedt@goodmis.org>
Cc: Daniel Wang <wonderfly@google.com>, stable@vger.kernel.org, pmladek@suse.com, Alexander.Levin@microsoft.com, akpm@linux-foundation.org, byungchul.park@lge.com, dave.hansen@intel.com, hannes@cmpxchg.org, jack@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mathieu.desnoyers@efficios.com, mgorman@suse.de, mhocko@kernel.org, penguin-kernel@I-love.SAKURA.ne.jp, peterz@infradead.org, tj@kernel.org, torvalds@linux-foundation.org, xiyou.wangcong@gmail.com, pfeiner@google.com

On 10/1/18 10:13 PM, Pavel Machek wrote:
> 
> Dunno. Is the patch perhaps a bit too complex? This is not exactly
> trivial bugfix.
> 
> pavel@duo:/data/l/clean-cg$ git show dbdda842fe96f | diffstat
>  printk.c |  108
>  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++-
> 
> I see that it is pretty critical to Daniel, but maybe kernel with
> console locking redone should no longer be called 4.4?

In that case it probably should no longer be called 4.4 since at least
Meltdown/Spectre fixes :)
