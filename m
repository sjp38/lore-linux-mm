Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id EFFFD6B000D
	for <linux-mm@kvack.org>; Fri, 22 Jun 2018 09:07:13 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id v127-v6so1686304ith.9
        for <linux-mm@kvack.org>; Fri, 22 Jun 2018 06:07:13 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id r137-v6si1163985itb.144.2018.06.22.06.07.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Jun 2018 06:07:12 -0700 (PDT)
Subject: Re: [PATCH] printk: inject caller information into the body of
 message
References: <20180524021451.GA23443@jagdpanzerIV>
 <CACT4Y+brbqfBWntjVaj-Ri2WhBdXpkA_PYs59qgLZ0vtepZEtw@mail.gmail.com>
 <CACT4Y+ZGSefrYL9xtQs=yPMRNFsOUumuJXsShJPhCOBSLySxuw@mail.gmail.com>
 <20180620083126.GA477@jagdpanzerIV>
 <CACT4Y+YMubTm1xduj+XCbQnNwQxYFLjBT33cFKisN1HyeaBpZw@mail.gmail.com>
 <20180620090413.GA444@jagdpanzerIV> <20180620091541.GB444@jagdpanzerIV>
 <CACT4Y+bcp4fSBBq3F86T-C4+n-YkeXUGMqpvkJ6vj6mK-TU2EA@mail.gmail.com>
 <20180620110759.GD444@jagdpanzerIV>
 <CACT4Y+aER3O2x2ApM=MVFoFXhp_T_rUeyG9CBx031qyH0voSRg@mail.gmail.com>
 <20180620130628.GA1000@tigerII.localdomain>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <197be25e-c841-bf3c-7081-61f0a9653c8c@i-love.sakura.ne.jp>
Date: Fri, 22 Jun 2018 22:06:45 +0900
MIME-Version: 1.0
In-Reply-To: <20180620130628.GA1000@tigerII.localdomain>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Dmitry Vyukov <dvyukov@google.com>, Fengguang Wu <fengguang.wu@intel.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Petr Mladek <pmladek@suse.com>, syzkaller <syzkaller@googlegroups.com>, Steven Rostedt <rostedt@goodmis.org>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>

On 2018/06/20 22:06, Sergey Senozhatsky wrote:
> On (06/20/18 13:32), Dmitry Vyukov wrote:
>>> So, if we could get rid of pr_cont() from the most important parts
>>> (instruction dumps, etc) then I would just vote to leave pr_cont()
>>> alone and avoid any handling of it in printk context tracking. Simply
>>> because we wouldn't care about pr_cont(). This also could simplify
>>> Tetsuo's patch significantly.
>>
>> Sounds good to me.
> 
> Awesome. If you and Fengguang can combine forces and lead the
> whole thing towards "we couldn't care of pr_cont() less", it
> would be really huuuuuge. Go for it!

Can't we have seq_printf()-like one which flushes automatically upon seeing '\n'
or buffer full? Printing memory information is using a lot of pr_cont(), even in
function names (e.g. http://lkml.kernel.org/r/20180622083949.GR10465@dhcp22.suse.cz ).
Since OOM killer code is serialized by oom_lock, we can use static buffer for
OOM killer messages.
