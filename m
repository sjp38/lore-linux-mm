Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id A0CE86B0088
	for <linux-mm@kvack.org>; Mon, 18 May 2015 04:11:11 -0400 (EDT)
Received: by wibt6 with SMTP id t6so59883928wib.0
        for <linux-mm@kvack.org>; Mon, 18 May 2015 01:11:11 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cg3si16521459wjb.89.2015.05.18.01.11.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 18 May 2015 01:11:10 -0700 (PDT)
Date: Mon, 18 May 2015 09:11:06 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: mm: BUG_ON with NUMA_BALANCING (kernel BUG at
 include/linux/swapops.h:131!)
Message-ID: <20150518081106.GW2462@suse.de>
References: <CACgMoiK61mKYFpfhhK51uvkvFHK3k+Dz4peMnbeW7-npDu4XBQ@mail.gmail.com>
 <20150514093304.GS2462@suse.de>
 <CACgMoiKzcDFTd7_howiH1KK2L-ky2S4x99-FTGS9pgO9Bqi0xg@mail.gmail.com>
 <CACgMoiKOQQXfnYK_QVLMQxy9R6rJtbHPNN+w4KrnoKYRiQDPEg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CACgMoiKOQQXfnYK_QVLMQxy9R6rJtbHPNN+w4KrnoKYRiQDPEg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Haren Myneni <hmyneni@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, Haren Myneni <hbabu@us.ibm.com>, aneesh.kumar@linux.vnet.ibm.com, srikar@linux.vnet.ibm.com

On Mon, May 18, 2015 at 12:32:29AM -0700, Haren Myneni wrote:
> Mel,
>     I am hitting this issue with 4.0 kernel and even with 3.19 and
> 3.17 kernels. I will also try with previous versions. Please let me
> know any suggestions on the debugging.
> 

Please keep going further back in time to see if there was a point where
this was ever working. It could be a ppc64-specific bug but right now,
I'm still drawing a blank.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
