Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 1F4EE6B0007
	for <linux-mm@kvack.org>; Tue,  5 Feb 2013 17:20:18 -0500 (EST)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Tue, 5 Feb 2013 17:20:17 -0500
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 6BED46E801C
	for <linux-mm@kvack.org>; Tue,  5 Feb 2013 17:20:11 -0500 (EST)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r15MKCiV296036
	for <linux-mm@kvack.org>; Tue, 5 Feb 2013 17:20:12 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r15MKCbC000850
	for <linux-mm@kvack.org>; Tue, 5 Feb 2013 20:20:12 -0200
Message-ID: <5111859B.7060004@linux.vnet.ibm.com>
Date: Tue, 05 Feb 2013 14:20:11 -0800
From: Cody P Schafer <cody@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 6/9] mm/page_alloc: add informative debugging message
 in page_outside_zone_boundaries()
References: <1358463181-17956-1-git-send-email-cody@linux.vnet.ibm.com> <1358463181-17956-7-git-send-email-cody@linux.vnet.ibm.com> <20130201162848.74bdb2a7.akpm@linux-foundation.org> <20130201162957.3ec618cf.akpm@linux-foundation.org>
In-Reply-To: <20130201162957.3ec618cf.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux MM <linux-mm@kvack.org>, David Hansen <dave@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Catalin Marinas <catalin.marinas@arm.com>

On 02/01/2013 04:29 PM, Andrew Morton wrote:
> On Fri, 1 Feb 2013 16:28:48 -0800
> Andrew Morton <akpm@linux-foundation.org> wrote:
>
>>> +	if (ret)
>>> +		pr_debug("page %lu outside zone [ %lu - %lu ]\n",
>>> +			pfn, start_pfn, start_pfn + sp);
>>> +
>>>   	return ret;
>>>   }
>>
>> As this condition leads to a VM_BUG_ON(), "pr_debug" seems rather wimpy
>> and I doubt if we need to be concerned about flooding the console.
>>
>> I'll switch it to pr_err.
>
> otoh, as nobody has ever hit that VM_BUG_ON() (yes?), do we really need
> the patch?

I've hit this bug while developing some code that moves pages between zones.

As it helped me debug that issue with my own code, I could see how 
another developer might be helped by it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
