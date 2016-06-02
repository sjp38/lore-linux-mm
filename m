Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9B7546B007E
	for <linux-mm@kvack.org>; Thu,  2 Jun 2016 04:21:49 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id m81so119139505vka.1
        for <linux-mm@kvack.org>; Thu, 02 Jun 2016 01:21:49 -0700 (PDT)
Received: from e38.co.us.ibm.com (e38.co.us.ibm.com. [32.97.110.159])
        by mx.google.com with ESMTPS id p21si37379323qka.202.2016.06.02.01.21.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 02 Jun 2016 01:21:48 -0700 (PDT)
Received: from localhost
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 2 Jun 2016 02:21:47 -0600
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH 1/4] mm/hugetlb: Simplify hugetlb unmap
In-Reply-To: <20160601153442.229f0747c97d1bbf21f1a935@linux-foundation.org>
References: <1464587062-17745-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20160601153442.229f0747c97d1bbf21f1a935@linux-foundation.org>
Date: Thu, 02 Jun 2016 13:51:41 +0530
Message-ID: <87twhcvw4q.fsf@skywalker.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Andrew Morton <akpm@linux-foundation.org> writes:

> On Mon, 30 May 2016 11:14:19 +0530 "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:
>
>> For hugetlb like THP (and unlike regular page), we do tlb flush after
>> dropping ptl. Because of the above, we don't need to track force_flush
>> like we do now. Instead we can simply call tlb_remove_page() which
>> will do the flush if needed.
>> 
>> No functionality change in this patch.
>
> This all looks fairly non-horrifying.  Will a non-RFC version be
> forthcoming?

Yes. I will send an updated version of the series. Patch 4 may need to go through
powerpc tree because of other dependent patches. I will continue to include
that in the series to show the arch related changes.
 
-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
