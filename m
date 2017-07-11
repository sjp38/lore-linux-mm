Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 290606B04BE
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 02:26:42 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id z1so29236124wrz.10
        for <linux-mm@kvack.org>; Mon, 10 Jul 2017 23:26:42 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d9si9889610wrc.290.2017.07.10.23.26.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 10 Jul 2017 23:26:41 -0700 (PDT)
Subject: Re: [RFC] mm/mremap: Remove redundant checks inside vma_expandable()
References: <20170710111059.30795-1-khandual@linux.vnet.ibm.com>
 <20170710134917.GB19645@dhcp22.suse.cz>
 <d6f9ec12-4518-8f97-eca9-6592808b839d@linux.vnet.ibm.com>
 <20170711060354.GA24852@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <4c182da0-6c84-df67-b173-6960fac0544a@suse.cz>
Date: Tue, 11 Jul 2017 08:26:40 +0200
MIME-Version: 1.0
In-Reply-To: <20170711060354.GA24852@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mike.kravetz@oracle.com

On 07/11/2017 08:03 AM, Michal Hocko wrote:
> On Tue 11-07-17 09:58:42, Anshuman Khandual wrote:
>>> here. This is hardly something that would save many cycles in a
>>> relatively cold path.
>>
>> Though I have not done any detailed instruction level measurement,
>> there is a reduction in real and system amount of time to execute
>> the test with and without the patch.
>>
>> Without the patch
>>
>> real	0m2.100s
>> user	0m0.162s
>> sys	0m1.937s
>>
>> With this patch
>>
>> real	0m0.928s
>> user	0m0.161s
>> sys	0m0.756s
> 
> Are you telling me that two if conditions cause more than a second
> difference? That sounds suspicious.

It's removing also a call to get_unmapped_area(), AFAICS. That means a
vma search?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
