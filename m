Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 44C1E6B0387
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 00:56:04 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id 203so17675204ith.3
        for <linux-mm@kvack.org>; Mon, 13 Feb 2017 21:56:04 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 31si13031241ios.181.2017.02.13.21.56.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Feb 2017 21:56:03 -0800 (PST)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1E5nN1E137463
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 00:56:03 -0500
Received: from e34.co.us.ibm.com (e34.co.us.ibm.com [32.97.110.152])
	by mx0b-001b2d01.pphosted.com with ESMTP id 28kthtbd09-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 00:56:03 -0500
Received: from localhost
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 13 Feb 2017 22:56:02 -0700
Subject: Re: [PATCH V2 1/2] mm/autonuma: Let architecture override how the
 write bit should be stashed in a protnone pte.
References: <1487050314-3892-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1487050314-3892-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <87poilmien.fsf@concordia.ellerman.id.au>
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Date: Tue, 14 Feb 2017 11:25:48 +0530
MIME-Version: 1.0
In-Reply-To: <87poilmien.fsf@concordia.ellerman.id.au>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Message-Id: <abd9d231-c380-95b0-0722-8df7be626968@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <michaele@au1.ibm.com>, akpm@linux-foundation.org, Rik van Riel <riel@surriel.com>, Mel Gorman <mgorman@techsingularity.net>, paulus@ozlabs.org, benh@kernel.crashing.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org



On Tuesday 14 February 2017 11:19 AM, Michael Ellerman wrote:
> "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> writes:
>
>> Autonuma preserves the write permission across numa fault to avoid taking
>> a writefault after a numa fault (Commit: b191f9b106ea " mm: numa: preserve PTE
>> write permissions across a NUMA hinting fault"). Architecture can implement
>> protnone in different ways and some may choose to implement that by clearing Read/
>> Write/Exec bit of pte. Setting the write bit on such pte can result in wrong
>> behaviour. Fix this up by allowing arch to override how to save the write bit
>> on a protnone pte.
> This is pretty obviously a nop on arches that don't implement the new
> hooks, but it'd still be good to get an ack from someone in mm land
> before I merge it.


To get it apply cleanly you may need
http://ozlabs.org/~akpm/mmots/broken-out/mm-autonuma-dont-use-set_pte_at-when-updating-protnone-ptes.patch
http://ozlabs.org/~akpm/mmots/broken-out/mm-autonuma-dont-use-set_pte_at-when-updating-protnone-ptes-fix.patch

They are strictly not needed after the saved write patch. But I didn't 
request to drop them, because the patch helps us
to get closer to the goal of no ste_pte_at() call on present ptes.

-aneesh


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
