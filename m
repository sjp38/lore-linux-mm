Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 962CA6B1EDD
	for <linux-mm@kvack.org>; Tue, 20 Nov 2018 02:43:03 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id v11so827905ply.4
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 23:43:03 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 11si40843484pgy.408.2018.11.19.23.43.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Nov 2018 23:43:02 -0800 (PST)
Date: Tue, 20 Nov 2018 08:42:59 +0100
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: request for 4.14-stable: fd5f7cde1b85 ("printk: Never set
 console_may_schedule in console_trylock()")
Message-ID: <20181120074259.GA15276@kroah.com>
References: <20181111202045.vocb3dthuquf7h2y@debian>
 <20181119151807.GE5340@kroah.com>
 <20181120022315.GA4231@jagdpanzerIV>
 <20181120022841.GB4231@jagdpanzerIV>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181120022841.GB4231@jagdpanzerIV>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Sudip Mukherjee <sudipm.mukherjee@gmail.com>, stable@vger.kernel.org, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Tejun Heo <tj@kernel.org>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Byungchul Park <byungchul.park@lge.com>, Pavel Machek <pavel@ucw.cz>, Steven Rostedt <rostedt@goodmis.org>, Petr Mladek <pmladek@suse.com>

On Tue, Nov 20, 2018 at 11:28:41AM +0900, Sergey Senozhatsky wrote:
> On (11/20/18 11:23), Sergey Senozhatsky wrote:
> > On (11/19/18 16:18), Greg Kroah-Hartman wrote:
> > > On Sun, Nov 11, 2018 at 08:20:45PM +0000, Sudip Mukherjee wrote:
> > > > Hi Greg,
> > > > 
> > > > This was not marked for stable but seems it should be in stable.
> > > > Please apply to your queue of 4.14-stable.
> > > 
> > > Now queued up, thanks.
> > 
> > Very sorry for the late reply!
> > 
> > Greg, Sudip, the commit in question is known to be controversial
> 
> Yikes!! PLEASE *IGNORE MY PREVIOUS EMAIL*!
> 
> 
> This is a *totally stupid* situation. I, somehow, got completely confused
> and looked at the wrong commit ID.
> 
> Really sorry!

No worries, email is now ignored :)

greg k-h
