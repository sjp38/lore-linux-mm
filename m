Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id D6FFB6B0007
	for <linux-mm@kvack.org>; Sun, 15 Apr 2018 10:42:54 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id a10-v6so6963425itb.1
        for <linux-mm@kvack.org>; Sun, 15 Apr 2018 07:42:54 -0700 (PDT)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0116.outbound.protection.outlook.com. [104.47.33.116])
        by mx.google.com with ESMTPS id d17si7512885ioc.256.2018.04.15.07.42.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 15 Apr 2018 07:42:53 -0700 (PDT)
From: Sasha Levin <Alexander.Levin@microsoft.com>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
Date: Sun, 15 Apr 2018 14:42:51 +0000
Message-ID: <20180415144248.GP2341@sasha-vm>
References: <20180409001936.162706-1-alexander.levin@microsoft.com>
 <20180409001936.162706-15-alexander.levin@microsoft.com>
 <20180409082246.34hgp3ymkfqke3a4@pathway.suse.cz>
In-Reply-To: <20180409082246.34hgp3ymkfqke3a4@pathway.suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <F6E90050B59FD7458ECD00BD16074263@namprd21.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Steven
 Rostedt (VMware)" <rostedt@goodmis.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>, Pavel Machek <pavel@ucw.cz>

On Mon, Apr 09, 2018 at 10:22:46AM +0200, Petr Mladek wrote:
>PS: I wonder how much time you give people to react before releasing
>this. The number of autosel mails is increasing and I am involved
>only in very small amount of them. I wonder if some other people
>gets overwhelmed by this.

My review cycle gives at least a week, and there's usually another week
until Greg releases them.

I know it's a lot of mails, but in reality it's a lot of commits that
should go in -stable.

Would a different format for review would make it easier?=
