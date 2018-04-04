Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id DD7B16B0005
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 06:53:51 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id q12-v6so11828495plr.17
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 03:53:51 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id g11si1873007pgs.153.2018.04.04.03.53.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Apr 2018 03:53:50 -0700 (PDT)
Subject: Re: WARNING in kill_block_super
References: <001a114043bcfab6ab05689518f9@google.com>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <6c95e826-4b9f-fb21-b311-830411e58480@I-love.SAKURA.ne.jp>
Date: Wed, 4 Apr 2018 19:53:07 +0900
MIME-Version: 1.0
In-Reply-To: <001a114043bcfab6ab05689518f9@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: viro@zeniv.linux.org.uk, Michal Hocko <mhocko@suse.com>
Cc: syzbot <syzbot+5a170e19c963a2e0df79@syzkaller.appspotmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, syzkaller-bugs@googlegroups.com, linux-mm <linux-mm@kvack.org>, Dmitry Vyukov <dvyukov@google.com>

Al and Michal, are you OK with this patch?
