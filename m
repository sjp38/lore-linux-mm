Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 622366B0003
	for <linux-mm@kvack.org>; Mon, 11 Jun 2018 06:57:19 -0400 (EDT)
Received: by mail-ot0-f198.google.com with SMTP id w15-v6so4471384otk.12
        for <linux-mm@kvack.org>; Mon, 11 Jun 2018 03:57:19 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id j41-v6si11691356otb.287.2018.06.11.03.57.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jun 2018 03:57:18 -0700 (PDT)
Subject: Re: INFO: task hung in collapse_huge_page
References: <000000000000a6d200056b14bfd4@google.com>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <e76ea707-b127-5071-4bcf-2ac472b0d106@I-love.SAKURA.ne.jp>
Date: Mon, 11 Jun 2018 19:56:34 +0900
MIME-Version: 1.0
In-Reply-To: <000000000000a6d200056b14bfd4@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: syzbot <syzbot+e65df5e4d866512cd91d@syzkaller.appspotmail.com>, syzkaller-bugs@googlegroups.com
Cc: akpm@linux-foundation.org, gregkh@linuxfoundation.org, hannes@cmpxchg.org, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, rientjes@google.com, shli@fb.com, sj38.park@gmail.com, willy@infradead.org, yang.s@alibaba-inc.com

khugepaged is trying to hold mm->mmap_sem for write, which is held
for read by a thread which is stuck at __sb_start_write(). Therefore,

#syz dup: INFO: task hung in __sb_start_write
