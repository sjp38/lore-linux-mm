Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id E7B876B0033
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 13:24:13 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id jz4so41549350wjb.5
        for <linux-mm@kvack.org>; Thu, 26 Jan 2017 10:24:13 -0800 (PST)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id 36si2954896wrp.148.2017.01.26.10.24.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jan 2017 10:24:12 -0800 (PST)
Received: by mail-wm0-x244.google.com with SMTP id d140so52405419wmd.2
        for <linux-mm@kvack.org>; Thu, 26 Jan 2017 10:24:12 -0800 (PST)
Date: Thu, 26 Jan 2017 20:24:08 +0200
From: Ahmed Samy <f.fallen45@gmail.com>
Subject: Re: ioremap_page_range: remapping of physical RAM ranges
Message-ID: <20170126182408.GA60252@devmasch>
References: <CADY3hbEy+oReL=DePFz5ZNsnvWpm55Q8=mRTxCGivSL64gAMMA@mail.gmail.com>
 <072b4406-16ef-cdf6-e968-711a60ca9a3f@nvidia.com>
 <20170125231529.GA14993@devmasch>
 <47fe454a-249d-967b-408f-83c5046615e4@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <47fe454a-249d-967b-408f-83c5046615e4@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: linux-mm@kvack.org, zhongjiang@huawei.com

On Thu, Jan 26, 2017 at 12:33:02AM -0800, John Hubbard wrote:
> 
> That's ioremap_page_range, I assume (rather than remap_page_range)?
Yes, I renamed it for your convience.

> 
> Overall, the remap_ram_range approach looks reasonable to me so far. I'll
> look into the details tomorrow.
> 
> I'm sure that most people on this list already know this, but...could you
> say a few more words about how remapping system ram is used, why it's a good
> thing and not a bad thing? :)
> 
It's useful for memory imaging tools, where you'd iterate through available ram
ranges, and dump it.  You could look at Google's Rekall, I am not sure if they
take the exact same approach.

Another use is mine, when I use EPT (GPA <-> HPA), let's say when I want to
write to a guest virtual address, then I first need to translate that into GPA,
then translate to HPA through EPT, and remap HPA to get a safe HVA, then I can write it to safely.
You can see a few use cases in the github link...  You could assume the same
for userspace to kernel space mapping, you mostly wouldn't trust the user
address passed, so you'd remap it to kernel space first (ptrace, whatever...).

	asamy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
