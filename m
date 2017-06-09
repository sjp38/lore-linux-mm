Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8FCA46B0279
	for <linux-mm@kvack.org>; Thu,  8 Jun 2017 22:54:29 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id m19so21790527pgd.14
        for <linux-mm@kvack.org>; Thu, 08 Jun 2017 19:54:29 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id u21si6035408pfj.0.2017.06.08.19.54.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Jun 2017 19:54:28 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v592rawx062699
	for <linux-mm@kvack.org>; Thu, 8 Jun 2017 22:54:28 -0400
Received: from e23smtp07.au.ibm.com (e23smtp07.au.ibm.com [202.81.31.140])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2aygma52e4-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 08 Jun 2017 22:54:27 -0400
Received: from localhost
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Fri, 9 Jun 2017 12:54:25 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v592sNCt57213008
	for <linux-mm@kvack.org>; Fri, 9 Jun 2017 12:54:23 +1000
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v592sL39006058
	for <linux-mm@kvack.org>; Fri, 9 Jun 2017 12:54:22 +1000
Subject: Re: [PATCH] mm: Define KB, MB, GB, TB in core VM
References: <20170522111742.29433-1-khandual@linux.vnet.ibm.com>
 <20170522141149.9ef84bb0713769f4af0383f0@linux-foundation.org>
 <20170523070227.GA27864@infradead.org>
 <09a6bafa-5743-425e-8def-bd9219cd756c@suse.cz>
 <161638da-3b2b-7912-2ae2-3b2936ca1537@linux.vnet.ibm.com>
 <7f85724c-6fc1-bb51-11e4-15fc2f89372b@linux.vnet.ibm.com>
 <87d1as6ifk.fsf@concordia.ellerman.id.au>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Fri, 9 Jun 2017 08:24:20 +0530
MIME-Version: 1.0
In-Reply-To: <87d1as6ifk.fsf@concordia.ellerman.id.au>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <b819bdda-10ac-01be-9198-c2323ecd142a@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <michaele@au1.ibm.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 05/29/2017 04:25 PM, Michael Ellerman wrote:
> Anshuman Khandual <khandual@linux.vnet.ibm.com> writes:
>>
>> So the question is are we willing to do all these changes across
>> the tree to achieve common definitions of KB, MB, GB, TB in the
>> kernel ? Is it worth ?
> 
> No I don't think it's worth the churn.
> 
> But have you looked at using the "proper" names, ie. KiB, MiB, GiB?
> 
> AFAICS the only clash is:
> 
> drivers/mtd/ssfdc.c:#define KiB(x)	( (x) * 1024L )
> drivers/mtd/ssfdc.c:#define MiB(x)	( KiB(x) * 1024L )
> 
> Which would be easy to convert.

Sure, will take a look into generalizing KiB/MiB/GiB instead of
current proposal for KB/MB/GB.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
