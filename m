Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 365E36B04C7
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 02:56:07 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id l34so29350282wrc.12
        for <linux-mm@kvack.org>; Mon, 10 Jul 2017 23:56:07 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y64si9634483wrc.160.2017.07.10.23.56.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 10 Jul 2017 23:56:06 -0700 (PDT)
Subject: Re: [RFC] mm/mremap: Remove redundant checks inside vma_expandable()
References: <20170710111059.30795-1-khandual@linux.vnet.ibm.com>
 <20170710134917.GB19645@dhcp22.suse.cz>
 <d6f9ec12-4518-8f97-eca9-6592808b839d@linux.vnet.ibm.com>
 <20170711060354.GA24852@dhcp22.suse.cz>
 <4c182da0-6c84-df67-b173-6960fac0544a@suse.cz>
 <20170711065030.GE24852@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <337a8a4c-1f27-7371-409d-6a9f181b3871@suse.cz>
Date: Tue, 11 Jul 2017 08:56:04 +0200
MIME-Version: 1.0
In-Reply-To: <20170711065030.GE24852@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mike.kravetz@oracle.com

On 07/11/2017 08:50 AM, Michal Hocko wrote:
> On Tue 11-07-17 08:26:40, Vlastimil Babka wrote:
>> On 07/11/2017 08:03 AM, Michal Hocko wrote:
>>>
>>> Are you telling me that two if conditions cause more than a second
>>> difference? That sounds suspicious.
>>
>> It's removing also a call to get_unmapped_area(), AFAICS. That means a
>> vma search?
> 
> Ohh, right. I have somehow missed that. Is this removal intentional?

I think it is: "Checking for availability of virtual address range at
the end of the VMA for the incremental size is also reduntant at this
point."

> The
> changelog is silent about it.

It doesn't explain why it's redundant, indeed. Unfortunately, the commit
f106af4e90ea ("fix checks for expand-in-place mremap") which added this,
also doesn't explain why it's needed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
