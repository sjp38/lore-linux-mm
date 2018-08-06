Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7C8846B0269
	for <linux-mm@kvack.org>; Mon,  6 Aug 2018 11:04:57 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id f13-v6so5717936pgs.15
        for <linux-mm@kvack.org>; Mon, 06 Aug 2018 08:04:57 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id 9-v6si13405151pgm.659.2018.08.06.08.04.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Aug 2018 08:04:56 -0700 (PDT)
Subject: Re: WARNING in try_charge
References: <39db7dbc-fedf-a86e-3c8b-0192e83d3c8d@i-love.sakura.ne.jp>
 <884de816-671a-44d4-a6a1-2ad7eff53715@I-love.SAKURA.ne.jp>
 <00000000000070698b0572c28ebc@google.com>
 <20180806113212.GK19540@dhcp22.suse.cz>
 <15945.1533567280@warthog.procyon.org.uk>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <3cc11dd9-6f83-741d-2e76-03c35865ee0b@i-love.sakura.ne.jp>
Date: Tue, 7 Aug 2018 00:04:38 +0900
MIME-Version: 1.0
In-Reply-To: <15945.1533567280@warthog.procyon.org.uk>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Howells <dhowells@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>, syzbot <syzbot+bab151e82a4e973fa325@syzkaller.appspotmail.com>, cgroups@vger.kernel.org, dvyukov@google.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, syzkaller-bugs@googlegroups.com, vdavydov.dev@gmail.com

On 2018/08/06 23:54, David Howells wrote:
> Do you have a link to the problem?
> 
> David
> 

https://groups.google.com/forum/#!msg/syzkaller-bugs/R03vI7RCVco/0PijCTrcCgAJ

syzbot found a reproducer, and the reproducer was working until next-20180803.
But the reproducer is failing to reproduce this problem in next-20180806 despite
there is no mm related change between next-20180803 and next-20180806.

Therefore, I suspect that the reproducer is no longer working as intended. And
there was parser change (your patch) between next-20180803 and next-20180806.
