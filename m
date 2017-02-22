Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id 182946B0387
	for <linux-mm@kvack.org>; Wed, 22 Feb 2017 10:49:23 -0500 (EST)
Received: by mail-vk0-f70.google.com with SMTP id 23so3578521vkc.1
        for <linux-mm@kvack.org>; Wed, 22 Feb 2017 07:49:23 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id g206si1869750ioa.230.2017.02.22.07.49.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Feb 2017 07:49:22 -0800 (PST)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1MFn0mD065463
	for <linux-mm@kvack.org>; Wed, 22 Feb 2017 10:49:22 -0500
Received: from e35.co.us.ibm.com (e35.co.us.ibm.com [32.97.110.153])
	by mx0b-001b2d01.pphosted.com with ESMTP id 28s9xgkrwa-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 22 Feb 2017 10:49:21 -0500
Received: from localhost
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <arbab@linux.vnet.ibm.com>;
	Wed, 22 Feb 2017 08:49:20 -0700
Date: Wed, 22 Feb 2017 09:49:12 -0600
From: Reza Arbab <arbab@linux.vnet.ibm.com>
Subject: Re: [HMM v17 00/14] HMM (Heterogeneous Memory Management) v17
References: <1485557541-7806-1-git-send-email-jglisse@redhat.com>
 <20170222071915.GE9967@balbir.ozlabs.ibm.com>
 <20170222001603.162a1209efc06b6c46556383@linux-foundation.org>
 <CAKTCnzmA3B4r956GXv8UKxmCTqxdt=uoXr4KBbvzzfc=ciz03A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <CAKTCnzmA3B4r956GXv8UKxmCTqxdt=uoXr4KBbvzzfc=ciz03A@mail.gmail.com>
Message-Id: <20170222154912.67crrt25zkkydip6@arbab-vm>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>, Aneesh Kumar KV <aneesh.kumar@linux.vnet.ibm.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, haren@linux.vnet.ibm.com

On Wed, Feb 22, 2017 at 07:27:10PM +1100, Balbir Singh wrote:
>On Wed, Feb 22, 2017 at 7:16 PM, Andrew Morton
><akpm@linux-foundation.org> wrote:
>> On Wed, 22 Feb 2017 18:19:15 +1100 Balbir Singh <bsingharora@gmail.com> wrote:
>>> Andrew, do we expect to get this in 4.11/4.12? Just curious.
>>>
>>
>> I'll be taking a serious look after -rc1.
>>
>> The lack of reviewed-by, acked-by and tested-by is a concern.  It's
>> rather odd for a patchset in the 17th revision!  What's up with that?
>>
>> Have you reviewed or tested the patches?
>
>I reviewed v14/15 of the patches. Aneesh reviewed some versions as
>well. I know a few people who tested a small subset of the patches,
>I'll get them to report back as well. I think John Hubbard has been
>testing iterations as well. CC'ing other interested people as well

I've been testing the migration helper subset in each version since v14.  
Apologies for not having chimed in.

Just sent a Tested-by for that part of v17.

-- 
Reza Arbab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
