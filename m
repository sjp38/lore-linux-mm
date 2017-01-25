Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7513D6B0038
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 05:19:59 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id r126so35901363wmr.2
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 02:19:59 -0800 (PST)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id q9si26283473wrc.80.2017.01.25.02.19.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jan 2017 02:19:58 -0800 (PST)
Date: Wed, 25 Jan 2017 11:19:57 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [RFC PATCH 1/2] mm, vmscan: account the number of isolated
	pages per zone
Message-ID: <20170125101957.GA17632@lst.de>
References: <20170118172944.GA17135@dhcp22.suse.cz> <20170119100755.rs6erdiz5u5by2pu@suse.de> <20170119112336.GN30786@dhcp22.suse.cz> <20170119131143.2ze5l5fwheoqdpne@suse.de> <201701202227.GCC13598.OHJMSQFVOtFOLF@I-love.SAKURA.ne.jp> <201701211642.JBC39590.SFtVJHMFOLFOQO@I-love.SAKURA.ne.jp> <20170125101517.GG32377@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170125101517.GG32377@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Christoph Hellwig <hch@lst.de>, mgorman@suse.de, viro@ZenIV.linux.org.uk, linux-mm@kvack.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org

On Wed, Jan 25, 2017 at 11:15:17AM +0100, Michal Hocko wrote:
> I think we are missing a check for fatal_signal_pending in
> iomap_file_buffered_write. This means that an oom victim can consume the
> full memory reserves. What do you think about the following? I haven't
> tested this but it mimics generic_perform_write so I guess it should
> work.

Hi Michal,

this looks reasonable to me.  But we have a few more such loops,
maybe it makes sense to move the check into iomap_apply?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
