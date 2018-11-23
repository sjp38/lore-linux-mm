Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5F22C6B3184
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 10:56:39 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id w7-v6so16014568plp.9
        for <linux-mm@kvack.org>; Fri, 23 Nov 2018 07:56:39 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 10si32892843pgk.101.2018.11.23.07.56.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Nov 2018 07:56:38 -0800 (PST)
Date: Fri, 23 Nov 2018 10:56:34 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 3/3] lockdep: Use line-buffered printk() for lockdep
 messages.
Message-ID: <20181123105634.4956c255@vmware.local.home>
In-Reply-To: <20181123124647.jmewvgrqdpra7wbm@pathway.suse.cz>
References: <1541165517-3557-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<1541165517-3557-3-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20181107151900.gxmdvx42qeanpoah@pathway.suse.cz>
	<20181108044510.GC2343@jagdpanzerIV>
	<9648a384-853c-942e-6a8d-80432d943aae@i-love.sakura.ne.jp>
	<20181109061204.GC599@jagdpanzerIV>
	<07dcbcb8-c5a7-8188-b641-c110ade1c5da@i-love.sakura.ne.jp>
	<20181109154326.apqkbsojmbg26o3b@pathway.suse.cz>
	<deb8d78b-0593-2b8e-1c7a-9203aa77005f@i-love.sakura.ne.jp>
	<20181123124647.jmewvgrqdpra7wbm@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Dmitriy Vyukov <dvyukov@google.com>, Alexander Potapenko <glider@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>

On Fri, 23 Nov 2018 13:46:47 +0100
Petr Mladek <pmladek@suse.com> wrote:

> Steven told me on Plumbers conference that even few initial
> characters saved him a day few times.

Yes, and that has happened more than once. I would reboot and retest
code that is crashing, and due to a triple fault, the machine would
reboot because of some race, and the little output I get from the
console would help tremendously.

Remember, debugging the kernel is a lot like forensics, especially when
it's from a customer's site. You look at all the evidence that you can
get, and sometimes it's just 10 characters in the output that gives you
an idea of where things went wrong. I'm really not liking the buffering
idea because of this.

-- Steve
