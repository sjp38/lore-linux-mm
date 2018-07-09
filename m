Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6EB0D6B02CC
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 08:56:10 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id w11-v6so5641377pfk.14
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 05:56:10 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id r11-v6si13631107pgs.274.2018.07.09.05.56.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Jul 2018 05:56:09 -0700 (PDT)
Subject: Re: BUG: corrupted list in cpu_stop_queue_work
References: <00000000000032412205706753b5@google.com>
 <000000000000693c7d057087caf3@google.com>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <1271c58e-876b-0df3-3224-319d82634663@I-love.SAKURA.ne.jp>
Date: Mon, 9 Jul 2018 21:55:17 +0900
MIME-Version: 1.0
In-Reply-To: <000000000000693c7d057087caf3@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: syzbot <syzbot+d8a8e42dfba0454286ff@syzkaller.appspotmail.com>, bigeasy@linutronix.de, linux-kernel@vger.kernel.org, matt@codeblueprint.co.uk, mingo@kernel.org, peterz@infradead.org, syzkaller-bugs@googlegroups.com, tglx@linutronix.de, linux-mm <linux-mm@kvack.org>

Hello Matthew,

It seems to me that there are other locations which do not check xas_store()
failure. Is that really OK? If they are OK, I think we want a comment like
/* This never fails. */ or /* Failure is OK because ... */
for each call without failure check.
