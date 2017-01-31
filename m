Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2D6B56B025E
	for <linux-mm@kvack.org>; Tue, 31 Jan 2017 08:21:45 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id r18so15807785wmd.1
        for <linux-mm@kvack.org>; Tue, 31 Jan 2017 05:21:45 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e56si20768714wre.332.2017.01.31.05.21.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 31 Jan 2017 05:21:43 -0800 (PST)
Date: Tue, 31 Jan 2017 14:21:41 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 1/2] mm, vmscan: account the number of isolated pages
 per zone
Message-ID: <20170131132141.GF19082@dhcp22.suse.cz>
References: <201701202227.GCC13598.OHJMSQFVOtFOLF@I-love.SAKURA.ne.jp>
 <201701211642.JBC39590.SFtVJHMFOLFOQO@I-love.SAKURA.ne.jp>
 <20170125101517.GG32377@dhcp22.suse.cz>
 <20170125101957.GA17632@lst.de>
 <20170125104605.GI32377@dhcp22.suse.cz>
 <201701252009.IHG13512.OFOJFSVLtOQMFH@I-love.SAKURA.ne.jp>
 <20170125130014.GO32377@dhcp22.suse.cz>
 <20170131115846.GD19082@dhcp22.suse.cz>
 <20170131125140.GA5298@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170131125140.GA5298@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, mgorman@suse.de, viro@ZenIV.linux.org.uk, linux-mm@kvack.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org

On Tue 31-01-17 13:51:40, Christoph Hellwig wrote:
> On Tue, Jan 31, 2017 at 12:58:46PM +0100, Michal Hocko wrote:
> > What do you think Christoph? I have an additional patch to handle
> > do_generic_file_read and a similar one to back off in
> > __vmalloc_area_node. I would like to post them all in one series but I
> > would like to know that this one is OK before I do that.
> 
> Well, that patch you posted is okay, but you probably need additional
> ones for the other interesting users of iomap_apply.

I have checked all of them I guees/hope. Which one you have in mind?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
