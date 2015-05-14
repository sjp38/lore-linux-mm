Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 7B7A06B0038
	for <linux-mm@kvack.org>; Thu, 14 May 2015 05:33:09 -0400 (EDT)
Received: by wguv19 with SMTP id v19so6936288wgu.1
        for <linux-mm@kvack.org>; Thu, 14 May 2015 02:33:09 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w6si2714567wiv.14.2015.05.14.02.33.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 14 May 2015 02:33:07 -0700 (PDT)
Date: Thu, 14 May 2015 10:33:04 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: mm: BUG_ON with NUMA_BALANCING (kernel BUG at
 include/linux/swapops.h:131!)
Message-ID: <20150514093304.GS2462@suse.de>
References: <CACgMoiK61mKYFpfhhK51uvkvFHK3k+Dz4peMnbeW7-npDu4XBQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CACgMoiK61mKYFpfhhK51uvkvFHK3k+Dz4peMnbeW7-npDu4XBQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Haren Myneni <hmyneni@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, Haren Myneni <hbabu@us.ibm.com>, aneesh.kumar@linux.vnet.ibm.com, srikar@linux.vnet.ibm.com

On Wed, May 13, 2015 at 01:17:54AM -0700, Haren Myneni wrote:
> Hi,
> 
>  I am getting BUG_ON in migration_entry_to_page() with 4.1.0-rc2
> kernel on powerpc system which has 512 CPUs (64 cores - 16 nodes) and
> 1.6 TB memory. We can easily recreate this issue with kernel compile
> (make -j500). But I could not reproduce with numa_balancing=disable.
> 

Is this patched in any way? I ask because line 134 on 4.1.0-rc2 does not
match up with a BUG_ON. It's close to a PageLocked check but I want to
be sure there are no other modifications.

Otherwise, when was the last time this worked? Was 4.0 ok? As it can be
easily reproduced, can the problem be bisected please?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
