Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 731EE6B0514
	for <linux-mm@kvack.org>; Wed,  9 May 2018 08:59:33 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id b64so26251934pfl.13
        for <linux-mm@kvack.org>; Wed, 09 May 2018 05:59:33 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id l9-v6si21096923pgq.691.2018.05.09.05.59.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 May 2018 05:59:32 -0700 (PDT)
Date: Wed, 9 May 2018 08:59:29 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH] printk: Ratelimit messages printed by console drivers
Message-ID: <20180509085929.180d1a93@gandalf.local.home>
In-Reply-To: <20180509120050.eyuprdh75grhdsh4@pathway.suse.cz>
References: <20180420140157.2nx5nkojj7l2y7if@pathway.suse.cz>
	<20180420101751.6c1c70e8@gandalf.local.home>
	<20180420145720.hb7bbyd5xbm5je32@pathway.suse.cz>
	<20180420111307.44008fc7@gandalf.local.home>
	<20180423103232.k23yulv2e7fah42r@pathway.suse.cz>
	<20180423073603.6b3294ba@gandalf.local.home>
	<20180423124502.423fb57thvbf3zet@pathway.suse.cz>
	<20180425053146.GA25288@jagdpanzerIV>
	<20180426094211.okftwdzgfn72rik3@pathway.suse.cz>
	<20180427102245.GA591@jagdpanzerIV>
	<20180509120050.eyuprdh75grhdsh4@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Tejun Heo <tj@kernel.org>, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On Wed, 9 May 2018 14:00:50 +0200
Petr Mladek <pmladek@suse.com> wrote:

> IMHO, if con->write() wants to add more than 1000 (or 100 or whatever
> sane limit) new lines then something is really wrong and we should
> stop it. It is that simple.
> 

+1

-- Steve
