Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5BDF26B0292
	for <linux-mm@kvack.org>; Fri, 21 Jul 2017 20:05:33 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id g6so29576120qkf.15
        for <linux-mm@kvack.org>; Fri, 21 Jul 2017 17:05:33 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id n60si4438355qte.464.2017.07.21.17.05.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jul 2017 17:05:32 -0700 (PDT)
Subject: Re: [PATCH] mm/hugetlb: __get_user_pages ignores certain
 follow_hugetlb_page errors
References: <1500406795-58462-1-git-send-email-daniel.m.jordan@oracle.com>
 <87o9sekux9.fsf@e105922-lin.cambridge.arm.com>
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Message-ID: <d8abb8b3-2b0e-9d15-9315-7ed7250165f0@oracle.com>
Date: Fri, 21 Jul 2017 20:05:02 -0400
MIME-Version: 1.0
In-Reply-To: <87o9sekux9.fsf@e105922-lin.cambridge.arm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Punit Agrawal <punit.agrawal@arm.com>
Cc: linux-mm@kvack.org, aarcange@redhat.com, akpm@linux-foundation.org, aneesh.kumar@linux.vnet.ibm.com, gerald.schaefer@de.ibm.com, james.morse@arm.com, kirill.shutemov@linux.intel.com, mhocko@suse.com, mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com, zhongjiang@huawei.com, linux-kernel@vger.kernel.org

Hi Punit,

On 07/21/2017 05:20 AM, Punit Agrawal wrote:
> The change makes sense.
> FWIW,
>
> Acked-by: Punit Agrawal <punit.agrawal@arm.com>

Thanks, I appreciate that.

> I was wondering how you hit the issue. Is there a test case that could
> have spotted this earlier?

This was actually just by inspection.

I checked selftests/vm, but there's nothing in there that would have 
come close to spotting this, so unfortunately there's no existing test case.

Thanks,
Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
