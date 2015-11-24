Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f180.google.com (mail-yk0-f180.google.com [209.85.160.180])
	by kanga.kvack.org (Postfix) with ESMTP id 2320C6B0038
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 15:29:00 -0500 (EST)
Received: by ykdv3 with SMTP id v3so32962592ykd.0
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 12:28:59 -0800 (PST)
Received: from mail-yk0-x235.google.com (mail-yk0-x235.google.com. [2607:f8b0:4002:c07::235])
        by mx.google.com with ESMTPS id f205si7004578ywc.70.2015.11.24.12.28.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Nov 2015 12:28:59 -0800 (PST)
Received: by ykba77 with SMTP id a77so32878594ykb.2
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 12:28:59 -0800 (PST)
Date: Tue, 24 Nov 2015 15:28:55 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v3 09/22] kthread: Allow to cancel kthread work
Message-ID: <20151124202855.GV17033@mtj.duckdns.org>
References: <1447853127-3461-1-git-send-email-pmladek@suse.com>
 <1447853127-3461-10-git-send-email-pmladek@suse.com>
 <20151123225823.GI19072@mtj.duckdns.org>
 <CA+55aFyW=hp-myZGcL+5r2x+fUbpBJLmxDY66QB5VQj-nNsCxQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFyW=hp-myZGcL+5r2x+fUbpBJLmxDY66QB5VQj-nNsCxQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Petr Mladek <pmladek@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm <linux-mm@kvack.org>, Vlastimil Babka <vbabka@suse.cz>, Linux API <linux-api@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

Hello,

On Tue, Nov 24, 2015 at 12:23:53PM -0800, Linus Torvalds wrote:
> instead (possibly just "spin_unlock_wait()" - but the explicit loop

I see.  Wasn't thinking about cache traffic.  Yeah, spin_unlock_wait()
seems a lot better.

> might be worth it if you then want to check the "canceling" flag
> independently of the lock state too).
> 
> In general, it's very dangerous to try to cook up your own locking
> rules. People *always* get it wrong.

It's either trylock on timer side or timer active spinning trick on
canceling side, so this seems the lesser of the two evils.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
