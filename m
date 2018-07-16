Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id AA24B6B0003
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 15:49:10 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id 123-v6so44356046qkg.8
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 12:49:10 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id d1-v6si12424516qvn.206.2018.07.16.12.49.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jul 2018 12:49:09 -0700 (PDT)
Subject: Re: [PATCH v1 00/10] mm: online/offline 4MB chunks controlled by
 device driver
From: David Hildenbrand <david@redhat.com>
References: <20180523151151.6730-1-david@redhat.com>
 <20180524075327.GU20441@dhcp22.suse.cz>
 <14d79dad-ad47-f090-2ec0-c5daf87ac529@redhat.com>
 <20180524093121.GZ20441@dhcp22.suse.cz>
 <c0b8bbd5-6c01-f550-ae13-ef80b2255ea6@redhat.com>
 <20180524120341.GF20441@dhcp22.suse.cz>
 <1a03ac4e-9185-ce8e-a672-c747c3e40ff2@redhat.com>
 <20180524142241.GJ20441@dhcp22.suse.cz>
 <819e45c5-6ae3-1dff-3f1d-c0411b6e2e1d@redhat.com>
 <3748f033-f349-6d88-d189-d77c76565981@redhat.com>
 <20180611115641.GL13364@dhcp22.suse.cz>
 <71bd1b65-2a88-5de7-9789-bf4fac26507d@redhat.com>
Message-ID: <e9697e6f-e562-a96c-7080-9271dbfbbea9@redhat.com>
Date: Mon, 16 Jul 2018 21:48:59 +0200
MIME-Version: 1.0
In-Reply-To: <71bd1b65-2a88-5de7-9789-bf4fac26507d@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexander Potapenko <glider@google.com>, Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Balbir Singh <bsingharora@gmail.com>, Baoquan He <bhe@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Dan Williams <dan.j.williams@intel.com>, Dave Young <dyoung@redhat.com>, Dmitry Vyukov <dvyukov@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Hari Bathini <hbathini@linux.vnet.ibm.com>, Huang Ying <ying.huang@intel.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@kernel.org>, Jaewon Kim <jaewon31.kim@samsung.com>, Jan Kara <jack@suse.cz>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Juergen Gross <jgross@suse.com>, Kate Stewart <kstewart@linuxfoundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <mawilcox@microsoft.com>, Mel Gorman <mgorman@suse.de>, Michael Ellerman <mpe@ellerman.id.au>, Miles Chen <miles.chen@mediatek.com>, Oscar Salvador <osalvador@techadventures.net>, Paul Mackerras <paulus@samba.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, Philippe Ombredanne <pombredanne@nexb.com>, Rashmica Gupta <rashmica.g@gmail.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Souptick Joarder <jrdr.linux@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Thomas Gleixner <tglx@linutronix.de>, Vlastimil Babka <vbabka@suse.cz>

On 11.06.2018 14:33, David Hildenbrand wrote:
> On 11.06.2018 13:56, Michal Hocko wrote:
>> On Mon 11-06-18 13:53:49, David Hildenbrand wrote:
>>> On 24.05.2018 23:07, David Hildenbrand wrote:
>>>> On 24.05.2018 16:22, Michal Hocko wrote:
>>>>> I will go over the rest of the email later I just wanted to make this
>>>>> point clear because I suspect we are talking past each other.
>>>>
>>>> It sounds like we are now talking about how to solve the problem. I like
>>>> that :)
>>>>
>>>
>>> Hi Michal,
>>>
>>> did you have time to think about the details of your proposed idea?
>>
>> Not really. Sorry about that. It's been busy time. I am planning to
>> revisit after merge window closes.
>>
> 
> Sure no worries, I still have a bunch of other things to work on. But it
> would be nice to clarify soon in which direction I have to head to get
> this implemented and upstream (e.g. what I proposed, what you proposed
> or maybe something different).
> 
I would really like to make progress here.

I pointed out basic problems/questions with the proposed alternative. I
think I answered all your questions. But you also said that you are not
going to accept the current approach. So some decision has to be made.

Although it's very demotivating and frustrating (I hope not all work in
the MM area will be like this), if there is no guidance on how to
proceed, I'll have to switch to adding/removing/onlining/offlining whole
segments. This is not what I want, but maybe this has a higher chance of
getting reviews/acks.

Understanding that you are busy, please if you make suggestions, follow
up on responses.

-- 

Thanks,

David / dhildenb
