Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7AE1D6B0005
	for <linux-mm@kvack.org>; Sat, 21 Apr 2018 06:27:35 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id n78so6077743pfj.4
        for <linux-mm@kvack.org>; Sat, 21 Apr 2018 03:27:35 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id s3-v6si7566807plb.394.2018.04.21.03.27.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 21 Apr 2018 03:27:34 -0700 (PDT)
Subject: Re: WARNING: refcount bug in should_fail
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <87lge5z6yn.fsf@xmission.com>
	<20180402215212.GF30522@ZenIV.linux.org.uk>
	<20180402215934.GG30522@ZenIV.linux.org.uk>
	<20180403052009.GH30522@ZenIV.linux.org.uk>
	<877epnj7bq.fsf@xmission.com>
In-Reply-To: <877epnj7bq.fsf@xmission.com>
Message-Id: <201804211926.EED90245.OOJHFVMLSQOtFF@I-love.SAKURA.ne.jp>
Date: Sat, 21 Apr 2018 19:26:52 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ebiederm@xmission.com, dvyukov@google.com
Cc: syzbot+84371b6062cb639d797e@syzkaller.appspotmail.com, syzkaller-bugs@googlegroups.com, viro@ZenIV.linux.org.uk, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org

Eric W. Biederman wrote:
> Al Viro <viro@ZenIV.linux.org.uk> writes:
> 
> > On Mon, Apr 02, 2018 at 10:59:34PM +0100, Al Viro wrote:
> >
> >> FWIW, I'm going through the ->kill_sb() instances, fixing that sort
> >> of bugs (most of them preexisting, but I should've checked instead
> >> of assuming that everything's fine).  Will push out later tonight.
> >
> > OK, see vfs.git#for-linus.  Caught: 4 old bugs (allocation failure
> > in fill_super oopses ->kill_sb() in hypfs, jffs2 and orangefs resp.
> > and double-dput in late failure exit in rpc_fill_super())
> > and 5 regressions from register_shrinker() failure recovery.
> 
> One issue with your vfs.git#for-linus branch.
> 
> It is missing Fixes tags and  Cc: stable on those patches.
> As the bug came in v4.15 those tags would really help the stable
> maintainers get the recent regression fixes applied.

OK. The patch was sent to linux.git as commit 8e04944f0ea8b838.

#syz fix: mm,vmscan: Allow preallocating memory for register_shrinker().
