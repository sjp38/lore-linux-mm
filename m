Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 590376B0033
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 08:13:49 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 14so272551091pgg.4
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 05:13:49 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id h5si1535154plk.30.2017.01.25.05.13.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 25 Jan 2017 05:13:48 -0800 (PST)
Subject: Re: [RFC PATCH 1/2] mm, vmscan: account the number of isolated pages per zone
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201701202227.GCC13598.OHJMSQFVOtFOLF@I-love.SAKURA.ne.jp>
	<201701211642.JBC39590.SFtVJHMFOLFOQO@I-love.SAKURA.ne.jp>
	<20170125101517.GG32377@dhcp22.suse.cz>
	<201701251933.GBH43798.OMQFFtOJHVFOSL@I-love.SAKURA.ne.jp>
	<20170125123446.GN32377@dhcp22.suse.cz>
In-Reply-To: <20170125123446.GN32377@dhcp22.suse.cz>
Message-Id: <201701252213.GBC87546.FQFVtMLJSFHOOO@I-love.SAKURA.ne.jp>
Date: Wed, 25 Jan 2017 22:13:34 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: hch@lst.de, mgorman@suse.de, viro@ZenIV.linux.org.uk, linux-mm@kvack.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Wed 25-01-17 19:33:59, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > I think we are missing a check for fatal_signal_pending in
> > > iomap_file_buffered_write. This means that an oom victim can consume the
> > > full memory reserves. What do you think about the following? I haven't
> > > tested this but it mimics generic_perform_write so I guess it should
> > > work.
> > 
> > Looks OK to me. I worried
> > 
> > #define AOP_FLAG_UNINTERRUPTIBLE        0x0001 /* will not do a short write */
> > 
> > which forbids (!?) aborting the loop. But it seems that this flag is
> > no longer checked (i.e. set but not used). So, everybody should be ready
> > for short write, although I don't know whether exofs / hfs / hfsplus are
> > doing appropriate error handling.
> 
> Those were using generic implementation before and that handles this
> case AFAICS.

What I wanted to say is: "We can remove AOP_FLAG_UNINTERRUPTIBLE completely
because grep does not find that flag used in condition check, can't we?".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
