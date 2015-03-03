Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f44.google.com (mail-oi0-f44.google.com [209.85.218.44])
	by kanga.kvack.org (Postfix) with ESMTP id 24E696B0038
	for <linux-mm@kvack.org>; Mon,  2 Mar 2015 20:31:31 -0500 (EST)
Received: by mail-oi0-f44.google.com with SMTP id a3so30516528oib.3
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 17:31:31 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id v8si7222238oeo.56.2015.03.02.17.31.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 02 Mar 2015 17:31:30 -0800 (PST)
Message-ID: <54F50EB1.5090102@oracle.com>
Date: Mon, 02 Mar 2015 17:30:25 -0800
From: Mike Kravetz <mike.kravetz@oracle.com>
MIME-Version: 1.0
Subject: Re: [RFC 2/3] hugetlbfs: coordinate global and subpool reserve accounting
References: <1425077893-18366-1-git-send-email-mike.kravetz@oracle.com>	<1425077893-18366-4-git-send-email-mike.kravetz@oracle.com> <20150302151023.e40dd1c6a9bf3d29cb6b657c@linux-foundation.org>
In-Reply-To: <20150302151023.e40dd1c6a9bf3d29cb6b657c@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nadia Yvette Chambers <nyc@holomorphy.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 03/02/2015 03:10 PM, Andrew Morton wrote:
> On Fri, 27 Feb 2015 14:58:11 -0800 Mike Kravetz <mike.kravetz@oracle.com> wrote:
>
>> If the pages for a subpool are reserved, then the reservations have
>> already been accounted for in the global pool.  Therefore, when
>> requesting a new reservation (such as for a mapping) for the subpool
>> do not count again in global pool.  However, when actually allocating
>> a page for the subpool decrement global reserve count to correspond to
>> with decrement in global free pages.
>
> The last sentence made my brain hurt.
>

Sorry.  I was trying to point out that the global free and reserve
accounting is still the same when doing a page allocation, even
though the entire size of the subpool was reserved.  For example,
when allocating a page the global free and reserve counts are both
decremented.

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
