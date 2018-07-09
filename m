Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 160626B02E8
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 10:34:29 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id y16-v6so7593669pfe.16
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 07:34:29 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id m39-v6si14861326plg.371.2018.07.09.07.34.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Jul 2018 07:34:28 -0700 (PDT)
Subject: Re: BUG: corrupted list in cpu_stop_queue_work
References: <00000000000032412205706753b5@google.com>
 <000000000000693c7d057087caf3@google.com>
 <1271c58e-876b-0df3-3224-319d82634663@I-love.SAKURA.ne.jp>
 <20180709133212.GA2662@bombadil.infradead.org>
 <8b258017-8817-8050-14a5-5e55c56bbf18@i-love.sakura.ne.jp>
 <20180709142445.GC2662@bombadil.infradead.org>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <877e8bf0-be4c-c481-64a7-1e793b2c4d4b@i-love.sakura.ne.jp>
Date: Mon, 9 Jul 2018 23:34:07 +0900
MIME-Version: 1.0
In-Reply-To: <20180709142445.GC2662@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: syzbot <syzbot+d8a8e42dfba0454286ff@syzkaller.appspotmail.com>, bigeasy@linutronix.de, linux-kernel@vger.kernel.org, matt@codeblueprint.co.uk, mingo@kernel.org, peterz@infradead.org, syzkaller-bugs@googlegroups.com, tglx@linutronix.de, linux-mm <linux-mm@kvack.org>

On 2018/07/09 23:24, Matthew Wilcox wrote:
>> Anyway, linux-next-20180709 still does not have this fix.
>> What is the title of your fix you pushed on Saturday?
> 
> I folded it into shmem: Convert shmem_add_to_page_cache to XArray.
> I can see it's fixed in today's linux-next.  I fixed it differently
> from the way you fixed it, so if you're looking for an xas_error check
> after xas_store, you won't find it.
> 

OK. linux-next-20180709 should no longer hit this bug. Closing with

#syz fix: shmem: Convert shmem_add_to_page_cache to XArray

Thanks.
