Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3BA116B0007
	for <linux-mm@kvack.org>; Sat, 21 Apr 2018 06:41:34 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id o9so3484947pgv.8
        for <linux-mm@kvack.org>; Sat, 21 Apr 2018 03:41:34 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id d69si6169795pgc.621.2018.04.21.03.41.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 21 Apr 2018 03:41:33 -0700 (PDT)
Subject: Re: WARNING: refcount bug in put_pid_ns
References: <001a113f8bf6c849030568bb75d3@google.com>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <44a322fa-6341-4b88-7f54-705c039f1538@I-love.SAKURA.ne.jp>
Date: Sat, 21 Apr 2018 19:41:21 +0900
MIME-Version: 1.0
In-Reply-To: <001a113f8bf6c849030568bb75d3@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: syzbot <syzbot+66a731f39da94bb14930@syzkaller.appspotmail.com>, syzkaller-bugs@googlegroups.com
Cc: gregkh@linuxfoundation.org, kstewart@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, pombredanne@nexb.com, tglx@linutronix.de

On 2018/04/01 5:47, syzbot wrote:
> Hello,
> 
> syzbot hit the following crash on upstream commit
> 9dd2326890d89a5179967c947dab2bab34d7ddee (Fri Mar 30 17:29:47 2018 +0000)
> Merge tag 'ceph-for-4.16-rc8' of git://github.com/ceph/ceph-client
> syzbot dashboard link: https://syzkaller.appspot.com/bug?extid=66a731f39da94bb14930

OK. The patch was sent to linux.git as commit 8e04944f0ea8b838.

#syz fix: mm,vmscan: Allow preallocating memory for register_shrinker().
