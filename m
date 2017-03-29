Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 516996B0390
	for <linux-mm@kvack.org>; Tue, 28 Mar 2017 20:07:47 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id o81so2848377itg.2
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 17:07:47 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id b77si6076475iob.144.2017.03.28.17.07.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Mar 2017 17:07:46 -0700 (PDT)
Subject: Re: mm: BUG in resv_map_release
References: <CACT4Y+Z-trVe0Oqzs8c+mTG6_iL7hPBBFgOm0p0iQsCz9Q2qiw@mail.gmail.com>
 <20170328163823.3a0445a058670be9254e115c@linux-foundation.org>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <8e87e893-526b-7324-33fb-783a544bab11@oracle.com>
Date: Tue, 28 Mar 2017 17:07:34 -0700
MIME-Version: 1.0
In-Reply-To: <20170328163823.3a0445a058670be9254e115c@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>
Cc: nyc@holomorphy.com, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Hillf Danton <hillf.zj@alibaba-inc.com>

On 03/28/2017 04:38 PM, Andrew Morton wrote:
> On Thu, 23 Mar 2017 11:19:38 +0100 Dmitry Vyukov <dvyukov@google.com> wrote:
> 
>> Hello,
>>
>> I've got the following BUG while running syzkaller fuzzer.
>> Note the injected kmalloc failure, most likely it's the root cause.
>>
> 
> Yes, probably the logic(?) in region_chg() leaked a
> resv->adds_in_progress++, although I'm not sure how.  And afaict that
> code can leak the memory at *nrg if the `trg' allocation attempt failed
> on the second or later pass around the retry loop.
> 
> Blah.  Does someone want to take a look at it?

I sent out a patch to address this and Hillf Acked.  Unfortunately,
there was a typo in your e-mail when I sent out the patch.  So, you
may not have noticed.

[PATCH] mm/hugetlb: Don't call region_abort if region_chg fails
http://marc.info/?l=linux-mm&m=149033588500724&w=2

If you need/want me to send again, let me know.
-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
