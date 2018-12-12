Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 14D328E00E5
	for <linux-mm@kvack.org>; Wed, 12 Dec 2018 16:01:52 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id o13so8186037otl.20
        for <linux-mm@kvack.org>; Wed, 12 Dec 2018 13:01:52 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id b9si7172554oif.84.2018.12.12.13.01.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Dec 2018 13:01:50 -0800 (PST)
Subject: Re: INFO: rcu detected stall in sys_mount (2)
References: <0000000000004a25cc057cd65aad@google.com>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <240fff25-0288-a0e6-a018-2e1593afc228@I-love.SAKURA.ne.jp>
Date: Thu, 13 Dec 2018 06:01:05 +0900
MIME-Version: 1.0
In-Reply-To: <0000000000004a25cc057cd65aad@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: syzbot <syzbot+5751b57c82cd229ffbee@syzkaller.appspotmail.com>, syzkaller-bugs@googlegroups.com
Cc: akpm@linux-foundation.org, amir73il@gmail.com, darrick.wong@oracle.com, david@fromorbit.com, hannes@cmpxchg.org, jrdr.linux@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org

Stalling inside __getblk_gfp()...

#syz dup: INFO: rcu detected stall in sys_creat
