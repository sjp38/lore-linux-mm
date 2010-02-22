Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 37A736B0047
	for <linux-mm@kvack.org>; Mon, 22 Feb 2010 03:16:57 -0500 (EST)
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate3.uk.ibm.com (8.13.1/8.13.1) with ESMTP id o1M8Gs8S001204
	for <linux-mm@kvack.org>; Mon, 22 Feb 2010 08:16:54 GMT
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o1M8Gr9m852172
	for <linux-mm@kvack.org>; Mon, 22 Feb 2010 08:16:53 GMT
Received: from d06av03.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id o1M8Grtx032377
	for <linux-mm@kvack.org>; Mon, 22 Feb 2010 08:16:53 GMT
Message-ID: <4B823D70.80800@linux.vnet.ibm.com>
Date: Mon, 22 Feb 2010 09:16:48 +0100
From: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] Make VM_MAX_READAHEAD a kernel parameter
References: <201002091659.27037.knikanth@suse.de> <201002111715.04411.knikanth@suse.de> <20100214213724.GA28392@discord.disaster> <201002151006.37294.knikanth@suse.de> <20100221142600.GA10036@localhost>
In-Reply-To: <20100221142600.GA10036@localhost>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Nikanth Karthikesan <knikanth@suse.de>, Dave Chinner <david@fromorbit.com>, Ankit Jain <radical@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Jens Axboe <jens.axboe@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>



Wu Fengguang wrote:
> Nikanth,
> 
>> I didn't want to impose artificial restrictions. I think Wu's patch set would 
>> be adding some restrictions, like minimum readahead. He could fix it when he 
>> modifies the patch to include in his patch set.
> 
> OK, I imposed a larger bound -- 128MB.
> And values 1-4095 (more exactly: PAGE_CACHE_SIZE) are prohibited mainly to 
> catch "readahead=128" where the user really means to do 128 _KB_ readahead.
> 
> Christian, with this patch and more patches to scale down readahead
> size on small memory/device size, I guess it's no longer necessary to
> introduce a CONFIG_READAHEAD_SIZE?

Yes as I mentioned before a kernel parameter supersedes a config symbol 
in my opinion too.
-> agreed

> Thanks,
> Fengguang
> ---

-- 

Grusse / regards, Christian Ehrhardt
IBM Linux Technology Center, System z Linux Performance

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
