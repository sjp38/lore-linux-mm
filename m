Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2D09F6B0003
	for <linux-mm@kvack.org>; Sun, 11 Nov 2018 15:20:50 -0500 (EST)
Received: by mail-wm1-f69.google.com with SMTP id r200-v6so7219044wmg.1
        for <linux-mm@kvack.org>; Sun, 11 Nov 2018 12:20:50 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id o15-v6sor4294277wmg.17.2018.11.11.12.20.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 11 Nov 2018 12:20:48 -0800 (PST)
Date: Sun, 11 Nov 2018 20:20:45 +0000
From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Subject: request for 4.14-stable: fd5f7cde1b85 ("printk: Never set
 console_may_schedule in console_trylock()")
Message-ID: <20181111202045.vocb3dthuquf7h2y@debian>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="ukql5mualcdcytsr"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: stable@vger.kernel.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Tejun Heo <tj@kernel.org>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Byungchul Park <byungchul.park@lge.com>, Pavel Machek <pavel@ucw.cz>, Steven Rostedt <rostedt@goodmis.org>, Petr Mladek <pmladek@suse.com>


--ukql5mualcdcytsr
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Greg,

This was not marked for stable but seems it should be in stable.
Please apply to your queue of 4.14-stable.

--
Regards
Sudip

--ukql5mualcdcytsr
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="0001-printk-Never-set-console_may_schedule-in-console_try.patch"


--ukql5mualcdcytsr--
