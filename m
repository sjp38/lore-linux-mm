Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id E4E5D6B1AFA
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 10:18:10 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id h10so6002069plk.12
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 07:18:10 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id h3-v6si43894138pfd.228.2018.11.19.07.18.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Nov 2018 07:18:09 -0800 (PST)
Date: Mon, 19 Nov 2018 16:18:07 +0100
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: request for 4.14-stable: fd5f7cde1b85 ("printk: Never set
 console_may_schedule in console_trylock()")
Message-ID: <20181119151807.GE5340@kroah.com>
References: <20181111202045.vocb3dthuquf7h2y@debian>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181111202045.vocb3dthuquf7h2y@debian>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Cc: stable@vger.kernel.org, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Tejun Heo <tj@kernel.org>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Byungchul Park <byungchul.park@lge.com>, Pavel Machek <pavel@ucw.cz>, Steven Rostedt <rostedt@goodmis.org>, Petr Mladek <pmladek@suse.com>

On Sun, Nov 11, 2018 at 08:20:45PM +0000, Sudip Mukherjee wrote:
> Hi Greg,
> 
> This was not marked for stable but seems it should be in stable.
> Please apply to your queue of 4.14-stable.

Now queued up, thanks.

greg k-h
