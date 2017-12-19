Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id E0FB76B0261
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 10:57:09 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id g12so7662962wra.2
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 07:57:09 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t134si1460846wmt.108.2017.12.19.07.57.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 19 Dec 2017 07:57:08 -0800 (PST)
Date: Tue, 19 Dec 2017 16:57:07 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [resend PATCH 0/2] fix VFS register_shrinker fixup
Message-ID: <20171219155707.GB2787@dhcp22.suse.cz>
References: <20171219132844.28354-1-mhocko@kernel.org>
 <20171219151915.GA2787@dhcp22.suse.cz>
 <20171219153418.GR21978@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171219153418.GR21978@ZenIV.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Aliaksei Karaliou <akaraliou.dev@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Tue 19-12-17 15:34:19, Al Viro wrote:
> On Tue, Dec 19, 2017 at 04:19:15PM +0100, Michal Hocko wrote:
> > Dohh, I have missed resend by Tetsuo http://lkml.kernel.org/r/1513596701-4518-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp
> > (thanks for dropping me from the CC).  Al seeemed to take the patch. We
> > still need patch 2. Al, are you going to take it from this thread or you
> > are going to go your way?
> 
> Umm... git log for-linus in vfs.git since yesterday:

OK, thanks!

> commit 9ee332d99e4d5a97548943b81c54668450ce641b
> Author: Al Viro <viro@zeniv.linux.org.uk>
> Date:   Mon Dec 18 15:05:07 2017 -0500
> 
>     sget(): handle failures of register_shrinker()
>     
>     Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
> 
> commit bb422a738f6566f7439cd347d54e321e4fe92a9f
> Author: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date:   Mon Dec 18 20:31:41 2017 +0900
> 
>     mm,vmscan: Make unregister_shrinker() no-op if register_shrinker() failed.
>     
>     Syzbot caught an oops at unregister_shrinker() because combination of
>     commit 1d3d4437eae1bb29 ("vmscan: per-node deferred work") and fault
>     injection made register_shrinker() fail and the caller of
>     register_shrinker() did not check for failure.
> ....

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
