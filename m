Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f200.google.com (mail-yb0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id 640FF6B0005
	for <linux-mm@kvack.org>; Mon, 30 Apr 2018 11:50:05 -0400 (EDT)
Received: by mail-yb0-f200.google.com with SMTP id q78-v6so6535276ybg.9
        for <linux-mm@kvack.org>; Mon, 30 Apr 2018 08:50:05 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id q5si2416464uaj.138.2018.04.30.08.50.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Apr 2018 08:50:04 -0700 (PDT)
Subject: Re: [PATCH RCFv2 1/7] mm: introduce and use PageOffline()
From: David Hildenbrand <david@redhat.com>
References: <20180430094236.29056-1-david@redhat.com>
 <20180430094236.29056-2-david@redhat.com>
 <4d112f60-3c24-585e-152e-b42d68c899a2@oracle.com>
 <28068791-bee4-095e-7338-cda4d229c3de@redhat.com>
Message-ID: <d9f6e3bc-5b36-4df6-e55a-d282eee9b050@redhat.com>
Date: Mon, 30 Apr 2018 17:49:59 +0200
MIME-Version: 1.0
In-Reply-To: <28068791-bee4-095e-7338-cda4d229c3de@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Philippe Ombredanne <pombredanne@nexb.com>, Thomas Gleixner <tglx@linutronix.de>, Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@suse.com>, Jan Kara <jack@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Matthew Wilcox <mawilcox@microsoft.com>, Souptick Joarder <jrdr.linux@gmail.com>, Hugh Dickins <hughd@google.com>, Huang Ying <ying.huang@intel.com>, Miles Chen <miles.chen@mediatek.com>, Vlastimil Babka <vbabka@suse.cz>, Reza Arbab <arbab@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>


>>
>>>
>>> -static void __meminit __init_single_page(struct page *page, unsigned long pfn,
>>> +extern void __meminit init_single_page(struct page *page, unsigned long pfn,
>>
>> I've seen it in other places, but what is the point of having "extern" function in .c file?
> 
> I've seen it all over the place, that's why I am using it :) (as I
> basically had the same question). Can somebody answer that?

BTW I was looking at the wrong file (header). This of course has to go!


-- 

Thanks,

David / dhildenb
