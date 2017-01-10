Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9E1D06B0069
	for <linux-mm@kvack.org>; Tue, 10 Jan 2017 18:37:55 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id dh1so80906698wjb.0
        for <linux-mm@kvack.org>; Tue, 10 Jan 2017 15:37:55 -0800 (PST)
Received: from mailapp01.imgtec.com (mailapp01.imgtec.com. [195.59.15.196])
        by mx.google.com with ESMTP id 31si2775397wrl.180.2017.01.10.15.37.54
        for <linux-mm@kvack.org>;
        Tue, 10 Jan 2017 15:37:54 -0800 (PST)
Subject: Re: [PATCH] mm: page_alloc: Skip over regions of invalid pfns where
 possible
References: <20161125185518.29885-1-paul.burton@imgtec.com>
 <20170106144348.f7d207baa7b3190a95aaeb2e@linux-foundation.org>
From: James Hartley <james.hartley@imgtec.com>
Message-ID: <0f03d5c6-182c-d30f-68ef-8d1a767bfcf8@imgtec.com>
Date: Tue, 10 Jan 2017 23:37:53 +0000
MIME-Version: 1.0
In-Reply-To: <20170106144348.f7d207baa7b3190a95aaeb2e@linux-foundation.org>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Paul Burton <paul.burton@imgtec.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org


On 06/01/17 22:43, Andrew Morton wrote:
> On Fri, 25 Nov 2016 18:55:18 +0000 Paul Burton <paul.burton@imgtec.com> wrote:
>
>> When using a sparse memory model memmap_init_zone() when invoked with
>> the MEMMAP_EARLY context will skip over pages which aren't valid - ie.
>> which aren't in a populated region of the sparse memory map. However if
>> the memory map is extremely sparse then it can spend a long time
>> linearly checking each PFN in a large non-populated region of the memory
>> map & skipping it in turn.
>>
>> When CONFIG_HAVE_MEMBLOCK_NODE_MAP is enabled, we have sufficient
>> information to quickly discover the next valid PFN given an invalid one
>> by searching through the list of memory regions & skipping forwards to
>> the first PFN covered by the memory region to the right of the
>> non-populated region. Implement this in order to speed up
>> memmap_init_zone() for systems with extremely sparse memory maps.
> Could we have a changelog which includes some timing measurements? 
> That permits others to understand the value of this patch.
>
I have tested this patch on a virtual model of a Samurai CPU with a
sparse memory map.  The kernel boot time drops from 109 to 62 seconds. 

James

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
