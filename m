Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id BB8496B0003
	for <linux-mm@kvack.org>; Tue,  3 Apr 2018 01:20:20 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id i4so8851599wrh.4
        for <linux-mm@kvack.org>; Mon, 02 Apr 2018 22:20:20 -0700 (PDT)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [195.92.253.2])
        by mx.google.com with ESMTPS id y81si1634641wmd.174.2018.04.02.22.20.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Apr 2018 22:20:19 -0700 (PDT)
Date: Tue, 3 Apr 2018 06:20:09 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: WARNING: refcount bug in should_fail
Message-ID: <20180403052009.GH30522@ZenIV.linux.org.uk>
References: <CACT4Y+aSEsoS60A0O0Ypg=kwRZV10SzUELbcG7KEkaTV7aMU5Q@mail.gmail.com>
 <94eb2c0b816e88bfc50568c6fed5@google.com>
 <201804011941.IAE69652.OHMVJLFtSOFFQO@I-love.SAKURA.ne.jp>
 <87lge5z6yn.fsf@xmission.com>
 <20180402215212.GF30522@ZenIV.linux.org.uk>
 <20180402215934.GG30522@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180402215934.GG30522@ZenIV.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, syzbot+@syzkaller.appspotmail.com, syzkaller-bugs@googlegroups.com, dvyukov@google.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org

On Mon, Apr 02, 2018 at 10:59:34PM +0100, Al Viro wrote:

> FWIW, I'm going through the ->kill_sb() instances, fixing that sort
> of bugs (most of them preexisting, but I should've checked instead
> of assuming that everything's fine).  Will push out later tonight.

OK, see vfs.git#for-linus.  Caught: 4 old bugs (allocation failure
in fill_super oopses ->kill_sb() in hypfs, jffs2 and orangefs resp.
and double-dput in late failure exit in rpc_fill_super())
and 5 regressions from register_shrinker() failure recovery.  
