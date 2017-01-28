Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id AEA506B026C
	for <linux-mm@kvack.org>; Sat, 28 Jan 2017 17:16:47 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 3so148462804pgj.6
        for <linux-mm@kvack.org>; Sat, 28 Jan 2017 14:16:47 -0800 (PST)
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id n3si8220371pfg.293.2017.01.28.14.16.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 28 Jan 2017 14:16:46 -0800 (PST)
Subject: Re: ioremap_page_range: remapping of physical RAM ranges
References: <CADY3hbEy+oReL=DePFz5ZNsnvWpm55Q8=mRTxCGivSL64gAMMA@mail.gmail.com>
 <072b4406-16ef-cdf6-e968-711a60ca9a3f@nvidia.com>
 <20170125231529.GA14993@devmasch>
 <47fe454a-249d-967b-408f-83c5046615e4@nvidia.com>
 <20170128211119.GA68646@devmasch>
 <9779dfc7-5af6-666a-2cca-08f7ddd30e34@nvidia.com>
 <20170128215504.GA69125@devmasch> <20170128221235.GA69602@devmasch>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <034a3124-10a0-13ad-cbe8-19864c01b2a5@nvidia.com>
Date: Sat, 28 Jan 2017 14:16:45 -0800
MIME-Version: 1.0
In-Reply-To: <20170128221235.GA69602@devmasch>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ahmed Samy <f.fallen45@gmail.com>
Cc: linux-mm@kvack.org, zhongjiang@huawei.com

On 01/28/2017 02:12 PM, Ahmed Samy wrote:
> On Sat, Jan 28, 2017 at 11:55:05PM +0200, Ahmed Samy wrote:
>> Take a look at `vmap()', it should be like that API.  Dunno if vmap can be used
>> in place, haven't tried, maybe can get `struct page` and then use vmap?  I
>> don't know, what do you think?
> OK, so, I just tried vmap() with a struct page retrieved by pfn_to_page() which
> seems to work just fine, so I suppose this can be disregarded, it's my fault; I
> should've done more research before posting this to the list.
>
> Sorry.

No problem at all, delighted to hear that your code will be OK!

thanks
john h


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
