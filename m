Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 068096B0260
	for <linux-mm@kvack.org>; Sat, 28 Jan 2017 16:55:10 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id r126so60316233wmr.2
        for <linux-mm@kvack.org>; Sat, 28 Jan 2017 13:55:09 -0800 (PST)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id h19si10816220wrc.243.2017.01.28.13.55.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 28 Jan 2017 13:55:08 -0800 (PST)
Received: by mail-wm0-x242.google.com with SMTP id c85so67256126wmi.1
        for <linux-mm@kvack.org>; Sat, 28 Jan 2017 13:55:08 -0800 (PST)
Date: Sat, 28 Jan 2017 23:55:05 +0200
From: Ahmed Samy <f.fallen45@gmail.com>
Subject: Re: ioremap_page_range: remapping of physical RAM ranges
Message-ID: <20170128215504.GA69125@devmasch>
References: <CADY3hbEy+oReL=DePFz5ZNsnvWpm55Q8=mRTxCGivSL64gAMMA@mail.gmail.com>
 <072b4406-16ef-cdf6-e968-711a60ca9a3f@nvidia.com>
 <20170125231529.GA14993@devmasch>
 <47fe454a-249d-967b-408f-83c5046615e4@nvidia.com>
 <20170128211119.GA68646@devmasch>
 <9779dfc7-5af6-666a-2cca-08f7ddd30e34@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9779dfc7-5af6-666a-2cca-08f7ddd30e34@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: linux-mm@kvack.org, zhongjiang@huawei.com

On Sat, Jan 28, 2017 at 01:48:46PM -0800, John Hubbard wrote:
> Quick question, what do you mean "a function as part of vmalloc"?
Take a look at `vmap()', it should be like that API.  Dunno if vmap can be used
in place, haven't tried, maybe can get `struct page` and then use vmap?  I
don't know, what do you think?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
