Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 32E726B0006
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 11:55:43 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id d6-v6so12811632plo.2
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 08:55:43 -0700 (PDT)
Received: from out03.mta.xmission.com (out03.mta.xmission.com. [166.70.13.233])
        by mx.google.com with ESMTPS id y38-v6si3444049plh.476.2018.04.04.08.55.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Apr 2018 08:55:42 -0700 (PDT)
From: ebiederm@xmission.com (Eric W. Biederman)
References: <CACT4Y+aSEsoS60A0O0Ypg=kwRZV10SzUELbcG7KEkaTV7aMU5Q@mail.gmail.com>
	<94eb2c0b816e88bfc50568c6fed5@google.com>
	<201804011941.IAE69652.OHMVJLFtSOFFQO@I-love.SAKURA.ne.jp>
	<87lge5z6yn.fsf@xmission.com>
	<20180402215212.GF30522@ZenIV.linux.org.uk>
	<20180402215934.GG30522@ZenIV.linux.org.uk>
	<20180403052009.GH30522@ZenIV.linux.org.uk>
Date: Wed, 04 Apr 2018 10:54:17 -0500
In-Reply-To: <20180403052009.GH30522@ZenIV.linux.org.uk> (Al Viro's message of
	"Tue, 3 Apr 2018 06:20:09 +0100")
Message-ID: <877epnj7bq.fsf@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain
Subject: Re: WARNING: refcount bug in should_fail
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, syzbot+@syzkaller.appspotmail.com, syzkaller-bugs@googlegroups.com, dvyukov@google.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org

Al Viro <viro@ZenIV.linux.org.uk> writes:

> On Mon, Apr 02, 2018 at 10:59:34PM +0100, Al Viro wrote:
>
>> FWIW, I'm going through the ->kill_sb() instances, fixing that sort
>> of bugs (most of them preexisting, but I should've checked instead
>> of assuming that everything's fine).  Will push out later tonight.
>
> OK, see vfs.git#for-linus.  Caught: 4 old bugs (allocation failure
> in fill_super oopses ->kill_sb() in hypfs, jffs2 and orangefs resp.
> and double-dput in late failure exit in rpc_fill_super())
> and 5 regressions from register_shrinker() failure recovery.

One issue with your vfs.git#for-linus branch.

It is missing Fixes tags and  Cc: stable on those patches.
As the bug came in v4.15 those tags would really help the stable
maintainers get the recent regression fixes applied.

Eric
