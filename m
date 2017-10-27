Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 345CD6B0033
	for <linux-mm@kvack.org>; Fri, 27 Oct 2017 00:06:49 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id v127so2728854wma.3
        for <linux-mm@kvack.org>; Thu, 26 Oct 2017 21:06:49 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id y89si446481eda.294.2017.10.26.21.06.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Oct 2017 21:06:47 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9R43pGP020241
	for <linux-mm@kvack.org>; Fri, 27 Oct 2017 00:06:46 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2duuqmvd3e-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 27 Oct 2017 00:06:45 -0400
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Fri, 27 Oct 2017 05:06:43 +0100
Subject: Re: [PATCH] mm/swap: Use page flags to determine LRU list in
 __activate_page()
References: <20171019145657.11199-1-khandual@linux.vnet.ibm.com>
 <20171019153322.c4uqalws7l7fdzcx@dhcp22.suse.cz>
 <d01827c0-8858-5688-dc16-1e2f597ec55c@linux.vnet.ibm.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Fri, 27 Oct 2017 09:36:37 +0530
MIME-Version: 1.0
In-Reply-To: <d01827c0-8858-5688-dc16-1e2f597ec55c@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <2fc28494-d0d2-9b65-aeb7-1ccabf210917@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, shli@kernel.org

On 10/23/2017 08:52 AM, Anshuman Khandual wrote:
> On 10/19/2017 09:03 PM, Michal Hocko wrote:
>> On Thu 19-10-17 20:26:57, Anshuman Khandual wrote:
>>> Its already assumed that the PageActive flag is clear on the input
>>> page, hence page_lru(page) will pick the base LRU for the page. In
>>> the same way page_lru(page) will pick active base LRU, once the
>>> flag PageActive is set on the page. This change of LRU list should
>>> happen implicitly through the page flags instead of being hard
>>> coded.
>>
>> The patch description tells what but it doesn't explain _why_? Does the
>> resulting code is better, more optimized or is this a pure readability
>> thing?
> 
> Not really. Not only it removes couple of lines of code but it also
> makes it look more logical from function flow point of view as well.
> 
>>
>> All I can see is that page_lru is more complex and a large part of it
>> can be optimized away which has been done manually here. I suspect the
>> compiler can deduce the same thing.
> 
> Why not ? I mean, that is the essence of the function page_lru() which
> should get us the exact LRU list the page should be on and hence we
> should not hand craft these manually.

Hi Michal,

Did not hear from you on this. So wondering what is the verdict
about this patch ?

- Anshuman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
