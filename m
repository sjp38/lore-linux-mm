Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f43.google.com (mail-la0-f43.google.com [209.85.215.43])
	by kanga.kvack.org (Postfix) with ESMTP id EEA6F6B008A
	for <linux-mm@kvack.org>; Mon, 18 May 2015 04:18:38 -0400 (EDT)
Received: by labbd9 with SMTP id bd9so207902058lab.2
        for <linux-mm@kvack.org>; Mon, 18 May 2015 01:18:38 -0700 (PDT)
Received: from mail-la0-x230.google.com (mail-la0-x230.google.com. [2a00:1450:4010:c03::230])
        by mx.google.com with ESMTPS id d5si2172648lag.4.2015.05.18.01.18.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 May 2015 01:18:37 -0700 (PDT)
Received: by lagr1 with SMTP id r1so126109415lag.0
        for <linux-mm@kvack.org>; Mon, 18 May 2015 01:18:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150518081106.GW2462@suse.de>
References: <CACgMoiK61mKYFpfhhK51uvkvFHK3k+Dz4peMnbeW7-npDu4XBQ@mail.gmail.com>
	<20150514093304.GS2462@suse.de>
	<CACgMoiKzcDFTd7_howiH1KK2L-ky2S4x99-FTGS9pgO9Bqi0xg@mail.gmail.com>
	<CACgMoiKOQQXfnYK_QVLMQxy9R6rJtbHPNN+w4KrnoKYRiQDPEg@mail.gmail.com>
	<20150518081106.GW2462@suse.de>
Date: Mon, 18 May 2015 01:18:36 -0700
Message-ID: <CACgMoi+r=2YaQ69QDcWUfFocornUy6Fzq3+OvWQS10wEt7-yxQ@mail.gmail.com>
Subject: Re: mm: BUG_ON with NUMA_BALANCING (kernel BUG at include/linux/swapops.h:131!)
From: Haren Myneni <hmyneni@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, Haren Myneni <hbabu@us.ibm.com>, aneesh.kumar@linux.vnet.ibm.com, srikar@linux.vnet.ibm.com

On 5/18/15, Mel Gorman <mgorman@suse.de> wrote:
> On Mon, May 18, 2015 at 12:32:29AM -0700, Haren Myneni wrote:
>> Mel,
>>     I am hitting this issue with 4.0 kernel and even with 3.19 and
>> 3.17 kernels. I will also try with previous versions. Please let me
>> know any suggestions on the debugging.
>>
>
> Please keep going further back in time to see if there was a point where
> this was ever working. It could be a ppc64-specific bug but right now,
> I'm still drawing a blank.

Sure, will do. I am running PPC64 LE kernel, but it does not show any
LE issue so far.

Thanks
Haren

>
> --
> Mel Gorman
> SUSE Labs
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
