Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 386536B0033
	for <linux-mm@kvack.org>; Tue, 31 Jan 2017 07:51:42 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id r18so15554446wmd.1
        for <linux-mm@kvack.org>; Tue, 31 Jan 2017 04:51:42 -0800 (PST)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id b26si20688216wra.300.2017.01.31.04.51.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Jan 2017 04:51:40 -0800 (PST)
Date: Tue, 31 Jan 2017 13:51:40 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [RFC PATCH 1/2] mm, vmscan: account the number of isolated
	pages per zone
Message-ID: <20170131125140.GA5298@lst.de>
References: <201701202227.GCC13598.OHJMSQFVOtFOLF@I-love.SAKURA.ne.jp> <201701211642.JBC39590.SFtVJHMFOLFOQO@I-love.SAKURA.ne.jp> <20170125101517.GG32377@dhcp22.suse.cz> <20170125101957.GA17632@lst.de> <20170125104605.GI32377@dhcp22.suse.cz> <201701252009.IHG13512.OFOJFSVLtOQMFH@I-love.SAKURA.ne.jp> <20170125130014.GO32377@dhcp22.suse.cz> <20170131115846.GD19082@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170131115846.GD19082@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Christoph Hellwig <hch@lst.de>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, mgorman@suse.de, viro@ZenIV.linux.org.uk, linux-mm@kvack.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org

On Tue, Jan 31, 2017 at 12:58:46PM +0100, Michal Hocko wrote:
> What do you think Christoph? I have an additional patch to handle
> do_generic_file_read and a similar one to back off in
> __vmalloc_area_node. I would like to post them all in one series but I
> would like to know that this one is OK before I do that.

Well, that patch you posted is okay, but you probably need additional
ones for the other interesting users of iomap_apply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
