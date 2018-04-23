Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 805C86B0005
	for <linux-mm@kvack.org>; Mon, 23 Apr 2018 07:36:08 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id s8so6373537pgf.0
        for <linux-mm@kvack.org>; Mon, 23 Apr 2018 04:36:08 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 44-v6si11157955pla.376.2018.04.23.04.36.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Apr 2018 04:36:07 -0700 (PDT)
Date: Mon, 23 Apr 2018 07:36:03 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH] printk: Ratelimit messages printed by console drivers
Message-ID: <20180423073603.6b3294ba@gandalf.local.home>
In-Reply-To: <20180423103232.k23yulv2e7fah42r@pathway.suse.cz>
References: <20180416014729.GB1034@jagdpanzerIV>
	<20180416042553.GA555@jagdpanzerIV>
	<20180419125353.lawdc3xna5oqlq7k@pathway.suse.cz>
	<20180420021511.GB6397@jagdpanzerIV>
	<20180420091224.cotxcfycmtt2hm4m@pathway.suse.cz>
	<20180420080428.622a8e7f@gandalf.local.home>
	<20180420140157.2nx5nkojj7l2y7if@pathway.suse.cz>
	<20180420101751.6c1c70e8@gandalf.local.home>
	<20180420145720.hb7bbyd5xbm5je32@pathway.suse.cz>
	<20180420111307.44008fc7@gandalf.local.home>
	<20180423103232.k23yulv2e7fah42r@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Tejun Heo <tj@kernel.org>, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On Mon, 23 Apr 2018 12:32:32 +0200
Petr Mladek <pmladek@suse.com> wrote:

> > Really?
> > 
> > 
> >   console_trylock_spinning(); /* console_owner now equals current */  
> 
> No, console_trylock_spinning() does not modify console_owner. The
> handshake is done using console_waiter variable.

Ug, you're right. Somehow when I looked at where console_owner was set
"console_lock_spinning_enabled" I saw it as "console_trylock_spinning".

This is what I get when I'm trying to follow three threads at the same
time :-/

> 
> console_owner is really set only between:
> 
>     console_lock_spinning_enable()
>     console_lock_spinning_disable_and_check()
> 
> and this entire section is called with interrupts disabled.

OK, I agree with you now. Although, one hour may still be too long.

-- Steve
