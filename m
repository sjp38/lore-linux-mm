Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m68IDSMU005603
	for <linux-mm@kvack.org>; Tue, 8 Jul 2008 14:13:28 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m68IDRw7198952
	for <linux-mm@kvack.org>; Tue, 8 Jul 2008 14:13:27 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m68IDR4C019831
	for <linux-mm@kvack.org>; Tue, 8 Jul 2008 14:13:27 -0400
Date: Tue, 8 Jul 2008 11:13:25 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [RFC PATCH 0/4] -mm-only hugetlb updates
Message-ID: <20080708181325.GG14908@us.ibm.com>
References: <20080708180348.GB14908@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080708180348.GB14908@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: mel@csn.ul.ie, agl@us.ibm.com, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 08.07.2008 [11:03:48 -0700], Nishanth Aravamudan wrote:
> As Nick requested, I've moved /sys/kernel/hugepages to
> /sys/kernel/mm/hugepages. I put the creation of the /sys/kernel/mm
> kobject in mm_init.c and that required removing the conditional
> compilation of that file. This also necessitated a bit of Documentation
> updates (and the addition of the /sys/kernel/mm ABI file). Finally, I
> realized that kobject usage doesn't require CONFIG_SYSFS, so I was able
> to remove one ifdef from hugetlb.c.
> 
> Andrew, I believe these patches, if acceptable, should be folded in
> place, if possible, in the hugetlb series (that is, the sysfs location
> should only ever have appeared to be /sys/kernel/mm/hugepages). The ease
> with which that can occur I guess depends on where Mel's
> DEBUG_MEMORY_INIT patches are in the series.
> 
> 1/4: mm: remove mm_init compilation dependency on CONFIG_DEBUG_MEMORY_INIT
> 2/4: mm: create /sys/kernel/mm
> 3/4: hugetlb: hang off of /sys/kernel/mm rather than /sys/kernel
> 4/4: hugetlb: remove CONFIG_SYSFS dependency

Sorry, stupid typo in Andrew's e-mail address. Andrew, will you grab the
patches (if acceptable) from the mailing list, or would you prefer I
resend?

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
