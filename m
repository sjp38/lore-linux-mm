Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id C208E6B026A
	for <linux-mm@kvack.org>; Sat, 28 Jan 2017 17:13:16 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id f144so401474735pfa.3
        for <linux-mm@kvack.org>; Sat, 28 Jan 2017 14:13:16 -0800 (PST)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id z87si8250575pfi.113.2017.01.28.14.13.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 28 Jan 2017 14:13:15 -0800 (PST)
Subject: Re: ioremap_page_range: remapping of physical RAM ranges
References: <CADY3hbEy+oReL=DePFz5ZNsnvWpm55Q8=mRTxCGivSL64gAMMA@mail.gmail.com>
 <072b4406-16ef-cdf6-e968-711a60ca9a3f@nvidia.com>
 <20170125231529.GA14993@devmasch>
 <47fe454a-249d-967b-408f-83c5046615e4@nvidia.com>
 <20170128211119.GA68646@devmasch>
 <9779dfc7-5af6-666a-2cca-08f7ddd30e34@nvidia.com>
 <20170128215504.GA69125@devmasch>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <e35e0e68-f753-3bdf-60c7-05992aed9870@nvidia.com>
Date: Sat, 28 Jan 2017 14:13:10 -0800
MIME-Version: 1.0
In-Reply-To: <20170128215504.GA69125@devmasch>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ahmed Samy <f.fallen45@gmail.com>
Cc: linux-mm@kvack.org, zhongjiang@huawei.com

On 01/28/2017 01:55 PM, Ahmed Samy wrote:
> On Sat, Jan 28, 2017 at 01:48:46PM -0800, John Hubbard wrote:
>> Quick question, what do you mean "a function as part of vmalloc"?
> Take a look at `vmap()', it should be like that API.  Dunno if vmap can be used
> in place, haven't tried, maybe can get `struct page` and then use vmap?  I
> don't know, what do you think?

Right, vmap is probably what you're looking for here. The way this story usually goes in my 
experience is: if you're actually dealing with real RAM, you are also dealing in struct pages. So 
you lookup the struct pages, keep track of them, (maybe also pin them with get_user_pages), and then 
map them with vmap.

Beyond the out-of-tree driver that I'm supporting (which uses vmap in that way), there are also a 
*lot* of in-tree examples that also do it.

Are you buying this? :)

thanks
john h

>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
