Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 43A726B0006
	for <linux-mm@kvack.org>; Tue,  7 Aug 2018 07:31:24 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id j14-v6so5296291edr.2
        for <linux-mm@kvack.org>; Tue, 07 Aug 2018 04:31:24 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f5-v6si1021528edn.275.2018.08.07.04.31.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Aug 2018 04:31:23 -0700 (PDT)
Subject: Re: [Bug 200651] New: cgroups iptables-restor: vmalloc: allocation
 failure
References: <8105b7b3-20d3-5931-9f3c-2858021a4e12@icdsoft.com>
 <20180731140520.kpotpihqsmiwhh7l@breakpoint.cc>
 <e5b24629-0296-5a4d-577a-c25d1c52b03b@suse.cz>
 <20180801083349.GF16767@dhcp22.suse.cz>
 <e5c5e965-a6bc-d61f-97fc-78da287b5d94@icdsoft.com>
 <20180802085043.GC10808@dhcp22.suse.cz>
 <85c86f17-6f96-6f01-2a3c-e2bad0ccb317@icdsoft.com>
 <5b5e872e-5785-2cfd-7d53-e19e017e5636@icdsoft.com>
 <20180807110951.GZ10003@dhcp22.suse.cz>
 <20180807111926.ibdkzgghn3nfugn2@breakpoint.cc>
 <20180807112641.GB10003@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <6a9460c1-cb63-27e1-dd29-da3f736cfa09@suse.cz>
Date: Tue, 7 Aug 2018 13:31:21 +0200
MIME-Version: 1.0
In-Reply-To: <20180807112641.GB10003@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Florian Westphal <fw@strlen.de>
Cc: Georgi Nikolov <gnikolov@icdsoft.com>, Andrew Morton <akpm@linux-foundation.org>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, netfilter-devel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

On 08/07/2018 01:26 PM, Michal Hocko wrote:
> On Tue 07-08-18 13:19:26, Florian Westphal wrote:
>> Michal Hocko <mhocko@kernel.org> wrote:
>>>> I can't reproduce it anymore.
>>>> If i understand correctly this way memory allocated will be
>>>> accounted to kmem of this cgroup (if inside cgroup).
>>>
>>> s@this@caller's@
>>>
>>> Florian, is this patch acceptable
>>
>> I am no mm expert.  Should all longlived GFP_KERNEL allocations set ACCOUNT?
> 
> No. We should focus only on those that are under direct userspace
> control and it can be triggered by an untrusted user.

Looks like the description in include/linux/gfp.h could use some details
to guide developers, possibly also Mike's new/improved docs (+CC).

>> If so, there are more places that should get same treatment.
>> The change looks fine to me, but again, I don't know when ACCOUNT should
>> be set in the first place.
> 
> see above.
> 
