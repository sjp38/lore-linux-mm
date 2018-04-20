Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1E6CC6B0008
	for <linux-mm@kvack.org>; Fri, 20 Apr 2018 10:19:19 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id b13so2842466pgw.1
        for <linux-mm@kvack.org>; Fri, 20 Apr 2018 07:19:19 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id z79si5725335pfa.120.2018.04.20.07.19.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Apr 2018 07:19:17 -0700 (PDT)
Date: Fri, 20 Apr 2018 10:19:15 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH] printk: Ratelimit messages printed by console drivers
Message-ID: <20180420101915.6cf5d4a4@gandalf.local.home>
In-Reply-To: <20180420101751.6c1c70e8@gandalf.local.home>
References: <20180413124704.19335-1-pmladek@suse.com>
	<20180413101233.0792ebf0@gandalf.local.home>
	<20180414023516.GA17806@tigerII.localdomain>
	<20180416014729.GB1034@jagdpanzerIV>
	<20180416042553.GA555@jagdpanzerIV>
	<20180419125353.lawdc3xna5oqlq7k@pathway.suse.cz>
	<20180420021511.GB6397@jagdpanzerIV>
	<20180420091224.cotxcfycmtt2hm4m@pathway.suse.cz>
	<20180420080428.622a8e7f@gandalf.local.home>
	<20180420140157.2nx5nkojj7l2y7if@pathway.suse.cz>
	<20180420101751.6c1c70e8@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Tejun Heo <tj@kernel.org>, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On Fri, 20 Apr 2018 10:17:51 -0400
Steven Rostedt <rostedt@goodmis.org> wrote:

> int git_context(void)

That should have been get_context(void) ;-)

-- Steve
