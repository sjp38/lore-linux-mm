Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 449EE6B0005
	for <linux-mm@kvack.org>; Wed,  1 Aug 2018 03:17:52 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id g11-v6so4078462edi.8
        for <linux-mm@kvack.org>; Wed, 01 Aug 2018 00:17:52 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s33-v6si2849055edm.148.2018.08.01.00.17.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Aug 2018 00:17:49 -0700 (PDT)
Subject: Re: [Bug 200651] New: cgroups iptables-restor: vmalloc: allocation
 failure
References: <ed7090ad-5004-3133-3faf-607d2a9fa90a@suse.cz>
 <d69d7a82-5b70-051f-a517-f602c3ef1fd7@suse.cz>
 <98788618-94dc-5837-d627-8bbfa1ddea57@icdsoft.com>
 <ff19099f-e0f5-d2b2-e124-cc12d2e05dc1@icdsoft.com>
 <20180730135744.GT24267@dhcp22.suse.cz>
 <89ea4f56-6253-4f51-0fb7-33d7d4b60cfa@icdsoft.com>
 <20180730183820.GA24267@dhcp22.suse.cz>
 <56597af4-73c6-b549-c5d5-b3a2e6441b8e@icdsoft.com>
 <6838c342-2d07-3047-e723-2b641bc6bf79@suse.cz>
 <8105b7b3-20d3-5931-9f3c-2858021a4e12@icdsoft.com>
 <20180731140520.kpotpihqsmiwhh7l@breakpoint.cc>
 <9cee281e-e6f4-20d1-401c-3c8b6fb744db@icdsoft.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5fb2cbce-d900-2ca6-84c8-29e8d87d1554@suse.cz>
Date: Wed, 1 Aug 2018 09:17:47 +0200
MIME-Version: 1.0
In-Reply-To: <9cee281e-e6f4-20d1-401c-3c8b6fb744db@icdsoft.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Georgi Nikolov <gnikolov@icdsoft.com>, Florian Westphal <fw@strlen.de>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, netfilter-devel@vger.kernel.org

On 07/31/2018 04:25 PM, Georgi Nikolov wrote:
> On 07/31/2018 05:05 PM, Florian Westphal wrote:
>> Georgi Nikolov <gnikolov@icdsoft.com> wrote:
>>>> No, I think that's rather for the netfilter folks to decide. However, it
>>>> seems there has been the debate already [1] and it was not found. The
>>>> conclusion was that __GFP_NORETRY worked fine before, so it should work
>>>> again after it's added back. But now we know that it doesn't...
>>>>
>>>> [1] https://lore.kernel.org/lkml/20180130140104.GE21609@dhcp22.suse.cz/T/#u
>>> Yes i see. I will add Florian Westphal to CC list. netfilter-devel is
>>> already in this list so probably have to wait for their opinion.
>> It hasn't changed, I think having OOM killer zap random processes
>> just because userspace wants to import large iptables ruleset is not a
>> good idea.
> And what about passing GFP_NORETRY only above some reasonable threshold?

What is the reasonable threshold?

> Or situation has to be handled in userspace.

How?

> 
> Regards,
> 
> --
> Georgi Nikolov
> 
