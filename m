Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 73AF58E0001
	for <linux-mm@kvack.org>; Fri, 28 Dec 2018 00:26:25 -0500 (EST)
Received: by mail-yb1-f198.google.com with SMTP id e205so6922750yba.21
        for <linux-mm@kvack.org>; Thu, 27 Dec 2018 21:26:25 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id 186-v6si23709747ybp.433.2018.12.27.21.26.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Dec 2018 21:26:24 -0800 (PST)
Subject: Re: bug report: hugetlbfs: use i_mmap_rwsem for more pmd sharing,
 synchronization
References: <5c8be807-03cd-991d-c79b-3c10a4d6d67b@canonical.com>
 <29441ca1-82f1-2e4b-13f6-ad4fe9ed4d0f@oracle.com>
 <20181227184518.4c689fcdca88325b841dfc71@linux-foundation.org>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <bcf7e166-9d01-1085-fb28-b01f020c7a1d@oracle.com>
Date: Thu, 27 Dec 2018 21:26:09 -0800
MIME-Version: 1.0
In-Reply-To: <20181227184518.4c689fcdca88325b841dfc71@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Colin Ian King <colin.king@canonical.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Stephen Rothwell <sfr@canb.auug.org.au>, stable@vger.kernel.org, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On 12/27/18 6:45 PM, Andrew Morton wrote:
> On Thu, 27 Dec 2018 11:24:31 -0800 Mike Kravetz <mike.kravetz@oracle.com> wrote:
>> It would be better to make an explicit check for mapping != null before
>> calling i_mmap_lock_write/try_to_unmap.  In this way, unrelated changes to
>> code above will not potentially lead to the possibility of mapping == null.
>>
>> I'm not sure what is the best way to handle this.  Below is an updated version
>> of the patch sent to Andrew.  I can also provide a simple patch to the patch
>> if that is easier.
>>
> 
> Below is the delta.  Please check it.  It seems to do more than the
> above implies.
> 
> Also, I have notes here that 
> 
> hugetlbfs-use-i_mmap_rwsem-for-more-pmd-sharing-synchronization.patch
> and
> hugetlbfs-use-i_mmap_rwsem-to-fix-page-fault-truncate-race.patch
> 
> have additional updates pending.  Due to emails such as
> 
> http://lkml.kernel.org/r/849f5202-2200-265f-7769-8363053e8373@oracle.com
> http://lkml.kernel.org/r/732c0b7d-5a4e-97a8-9677-30f3520893cb@oracle.com
> http://lkml.kernel.org/r/6b91dd42-b903-1f6c-729a-bd9f51273986@oracle.com
> 
> What's the status, please?
> 

There was a V3 of the patches which was Acked-by Kirill.   See,
http://lkml.kernel.org/r/20181224101349.jjjmk2hzwah6g64h@kshutemo-mobl1

The two V3 patches are:
http://lkml.kernel.org/r/20181222223013.22193-2-mike.kravetz@oracle.com
http://lkml.kernel.org/r/20181222223013.22193-3-mike.kravetz@oracle.com

The patch I sent in this thread was an update to the V3.  The delta you
created was based on V2.  So, the delta contains V2 -> V3 changes as well
as the changes mentioned in this thread.  My apologies for not noticing
and clarifying.

Let me know what you would like me to do to help.  I hate to send any
more patches right now as they might cause more confusion.
-- 
Mike Kravetz
