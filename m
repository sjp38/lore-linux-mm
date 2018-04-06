Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id D08C56B0007
	for <linux-mm@kvack.org>; Fri,  6 Apr 2018 04:09:24 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id t133so369595wmt.6
        for <linux-mm@kvack.org>; Fri, 06 Apr 2018 01:09:24 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v101si7014579wrb.396.2018.04.06.01.09.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 06 Apr 2018 01:09:23 -0700 (PDT)
Date: Fri, 6 Apr 2018 10:09:22 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: WARNING in kill_block_super
Message-ID: <20180406080922.GH8286@dhcp22.suse.cz>
References: <001a114043bcfab6ab05689518f9@google.com>
 <6c95e826-4b9f-fb21-b311-830411e58480@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6c95e826-4b9f-fb21-b311-830411e58480@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: viro@zeniv.linux.org.uk, syzbot <syzbot+5a170e19c963a2e0df79@syzkaller.appspotmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, syzkaller-bugs@googlegroups.com, linux-mm <linux-mm@kvack.org>, Dmitry Vyukov <dvyukov@google.com>

On Wed 04-04-18 19:53:07, Tetsuo Handa wrote:
> Al and Michal, are you OK with this patch?

Maybe I've misunderstood, but hasn't Al explained [1] that the
appropriate fix is in the fs code?

[1] http://lkml.kernel.org/r/20180402143415.GC30522@ZenIV.linux.org.uk
-- 
Michal Hocko
SUSE Labs
