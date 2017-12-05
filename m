Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2D3106B0033
	for <linux-mm@kvack.org>; Mon,  4 Dec 2017 21:52:30 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id u3so14939210pfl.5
        for <linux-mm@kvack.org>; Mon, 04 Dec 2017 18:52:30 -0800 (PST)
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id r22si10319964pgo.706.2017.12.04.18.52.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Dec 2017 18:52:28 -0800 (PST)
Subject: Re: [PATCH v2] mmap.2: MAP_FIXED updated documentation
References: <20171204021411.4786-1-jhubbard@nvidia.com>
 <20171204113113.GA13465@rapoport-lnx>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <6777116d-ad9e-48c9-0009-01d10274135e@nvidia.com>
Date: Mon, 4 Dec 2017 18:52:27 -0800
MIME-Version: 1.0
In-Reply-To: <20171204113113.GA13465@rapoport-lnx>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Michael Kerrisk <mtk.manpages@gmail.com>, linux-man <linux-man@vger.kernel.org>, linux-api@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org, Jann Horn <jannh@google.com>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>

On 12/04/2017 03:31 AM, Mike Rapoport wrote:
> On Sun, Dec 03, 2017 at 06:14:11PM -0800, john.hubbard@gmail.com wrote:
>> From: John Hubbard <jhubbard@nvidia.com>
>>
[...]
>> +.IP
>> +Given the above limitations, one of the very few ways to use this option
>> +safely is: mmap() a region, without specifying MAP_FIXED. Then, within that
>> +region, call mmap(MAP_FIXED) to suballocate regions. This avoids both the
>> +portability problem (because the first mmap call lets the kernel pick the
>> +address), and the address space corruption problem (because the region being
>> +overwritten is already owned by the calling thread).
> 
> Maybe "address space corruption problem caused by implicit calls to mmap"?
> The region allocated with the first mmap is not exactly owned by the
> thread and a multi-thread application can still corrupt its memory if
> different threads use mmap(MAP_FIXED) for overlapping regions.
> 
> My 2 cents.
> 

Hi Mike,

Yes, thanks for picking through this, and I agree that the above is misleading.
It should definitely not use the word "owned" at all. Re-doing the whole 
paragraph in order to make it all fit together nicely, I get this:

"Given the above limitations, one of the very few ways to use this option
safely is: mmap() an enclosing region, without specifying MAP_FIXED.
Then, within that region, call mmap(MAP_FIXED) to suballocate regions
within the enclosing region. This avoids both the portability problem 
(because the first mmap call lets the kernel pick the address), and the 
address space corruption problem (because implicit calls to mmap will 
not affect the already-mapped enclosing region)."

...how's that sound to you? I'll post a v3 soon with this.


thanks,
John Hubbard
NVIDIA

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
