Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8CC266B0069
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 05:34:18 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id j18so11622780ioe.3
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 02:34:18 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id w19si19237276ioi.6.2017.01.25.02.34.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 25 Jan 2017 02:34:17 -0800 (PST)
Subject: Re: [RFC PATCH 1/2] mm, vmscan: account the number of isolated pagesper zone
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170119112336.GN30786@dhcp22.suse.cz>
	<20170119131143.2ze5l5fwheoqdpne@suse.de>
	<201701202227.GCC13598.OHJMSQFVOtFOLF@I-love.SAKURA.ne.jp>
	<201701211642.JBC39590.SFtVJHMFOLFOQO@I-love.SAKURA.ne.jp>
	<20170125101517.GG32377@dhcp22.suse.cz>
In-Reply-To: <20170125101517.GG32377@dhcp22.suse.cz>
Message-Id: <201701251933.GBH43798.OMQFFtOJHVFOSL@I-love.SAKURA.ne.jp>
Date: Wed, 25 Jan 2017 19:33:59 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, hch@lst.de
Cc: mgorman@suse.de, viro@ZenIV.linux.org.uk, linux-mm@kvack.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> I think we are missing a check for fatal_signal_pending in
> iomap_file_buffered_write. This means that an oom victim can consume the
> full memory reserves. What do you think about the following? I haven't
> tested this but it mimics generic_perform_write so I guess it should
> work.

Looks OK to me. I worried

#define AOP_FLAG_UNINTERRUPTIBLE        0x0001 /* will not do a short write */

which forbids (!?) aborting the loop. But it seems that this flag is
no longer checked (i.e. set but not used). So, everybody should be ready
for short write, although I don't know whether exofs / hfs / hfsplus are
doing appropriate error handling.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
