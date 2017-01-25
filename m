Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 081FC6B0033
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 07:34:50 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id v77so37498785wmv.5
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 04:34:49 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a39si26756071wra.119.2017.01.25.04.34.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 25 Jan 2017 04:34:48 -0800 (PST)
Date: Wed, 25 Jan 2017 13:34:46 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 1/2] mm, vmscan: account the number of isolated
 pagesper zone
Message-ID: <20170125123446.GN32377@dhcp22.suse.cz>
References: <20170119112336.GN30786@dhcp22.suse.cz>
 <20170119131143.2ze5l5fwheoqdpne@suse.de>
 <201701202227.GCC13598.OHJMSQFVOtFOLF@I-love.SAKURA.ne.jp>
 <201701211642.JBC39590.SFtVJHMFOLFOQO@I-love.SAKURA.ne.jp>
 <20170125101517.GG32377@dhcp22.suse.cz>
 <201701251933.GBH43798.OMQFFtOJHVFOSL@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201701251933.GBH43798.OMQFFtOJHVFOSL@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: hch@lst.de, mgorman@suse.de, viro@ZenIV.linux.org.uk, linux-mm@kvack.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org

On Wed 25-01-17 19:33:59, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > I think we are missing a check for fatal_signal_pending in
> > iomap_file_buffered_write. This means that an oom victim can consume the
> > full memory reserves. What do you think about the following? I haven't
> > tested this but it mimics generic_perform_write so I guess it should
> > work.
> 
> Looks OK to me. I worried
> 
> #define AOP_FLAG_UNINTERRUPTIBLE        0x0001 /* will not do a short write */
> 
> which forbids (!?) aborting the loop. But it seems that this flag is
> no longer checked (i.e. set but not used). So, everybody should be ready
> for short write, although I don't know whether exofs / hfs / hfsplus are
> doing appropriate error handling.

Those were using generic implementation before and that handles this
case AFAICS.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
