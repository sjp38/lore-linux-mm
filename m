Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id C49B96B0266
	for <linux-mm@kvack.org>; Sat, 28 Jan 2017 17:12:40 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id x4so32028wme.3
        for <linux-mm@kvack.org>; Sat, 28 Jan 2017 14:12:40 -0800 (PST)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id p187si7735082wmp.96.2017.01.28.14.12.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 28 Jan 2017 14:12:39 -0800 (PST)
Received: by mail-wm0-x244.google.com with SMTP id r126so67477543wmr.3
        for <linux-mm@kvack.org>; Sat, 28 Jan 2017 14:12:39 -0800 (PST)
Date: Sun, 29 Jan 2017 00:12:35 +0200
From: Ahmed Samy <f.fallen45@gmail.com>
Subject: Re: ioremap_page_range: remapping of physical RAM ranges
Message-ID: <20170128221235.GA69602@devmasch>
References: <CADY3hbEy+oReL=DePFz5ZNsnvWpm55Q8=mRTxCGivSL64gAMMA@mail.gmail.com>
 <072b4406-16ef-cdf6-e968-711a60ca9a3f@nvidia.com>
 <20170125231529.GA14993@devmasch>
 <47fe454a-249d-967b-408f-83c5046615e4@nvidia.com>
 <20170128211119.GA68646@devmasch>
 <9779dfc7-5af6-666a-2cca-08f7ddd30e34@nvidia.com>
 <20170128215504.GA69125@devmasch>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170128215504.GA69125@devmasch>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: linux-mm@kvack.org, zhongjiang@huawei.com

On Sat, Jan 28, 2017 at 11:55:05PM +0200, Ahmed Samy wrote:
> Take a look at `vmap()', it should be like that API.  Dunno if vmap can be used
> in place, haven't tried, maybe can get `struct page` and then use vmap?  I
> don't know, what do you think?
OK, so, I just tried vmap() with a struct page retrieved by pfn_to_page() which
seems to work just fine, so I suppose this can be disregarded, it's my fault; I
should've done more research before posting this to the list.

Sorry.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
