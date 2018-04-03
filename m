Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id A33936B0003
	for <linux-mm@kvack.org>; Tue,  3 Apr 2018 07:28:04 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id w9-v6so7327557plp.0
        for <linux-mm@kvack.org>; Tue, 03 Apr 2018 04:28:04 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id y2-v6sor479426pli.110.2018.04.03.04.28.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 03 Apr 2018 04:28:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180403052009.GH30522@ZenIV.linux.org.uk>
References: <CACT4Y+aSEsoS60A0O0Ypg=kwRZV10SzUELbcG7KEkaTV7aMU5Q@mail.gmail.com>
 <94eb2c0b816e88bfc50568c6fed5@google.com> <201804011941.IAE69652.OHMVJLFtSOFFQO@I-love.SAKURA.ne.jp>
 <87lge5z6yn.fsf@xmission.com> <20180402215212.GF30522@ZenIV.linux.org.uk>
 <20180402215934.GG30522@ZenIV.linux.org.uk> <20180403052009.GH30522@ZenIV.linux.org.uk>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 3 Apr 2018 13:27:42 +0200
Message-ID: <CACT4Y+YM9m+t7cDPMYpK93mMi1mcq+3-WutYu23db7KiwU8MrQ@mail.gmail.com>
Subject: Re: WARNING: refcount bug in should_fail
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, syzbot <syzbot+@syzkaller.appspotmail.com>, syzkaller-bugs@googlegroups.com, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, netdev <netdev@vger.kernel.org>

On Tue, Apr 3, 2018 at 7:20 AM, Al Viro <viro@zeniv.linux.org.uk> wrote:
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

Nice!
