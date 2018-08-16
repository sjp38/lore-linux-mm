Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 035A86B026B
	for <linux-mm@kvack.org>; Thu, 16 Aug 2018 08:08:53 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id 2-v6so4112678ywn.13
        for <linux-mm@kvack.org>; Thu, 16 Aug 2018 05:08:52 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id h41-v6si2764005qta.97.2018.08.16.05.08.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Aug 2018 05:08:52 -0700 (PDT)
Subject: Re: [PATCH v1 1/5] mm/memory_hotplug: drop intermediate
 __offline_pages
References: <20180816100628.26428-1-david@redhat.com>
 <20180816100628.26428-2-david@redhat.com>
 <20180816214459.64a7cec3@canb.auug.org.au>
From: David Hildenbrand <david@redhat.com>
Message-ID: <265ca413-110b-cc93-ae63-e9780a96358e@redhat.com>
Date: Thu, 16 Aug 2018 14:08:46 +0200
MIME-Version: 1.0
In-Reply-To: <20180816214459.64a7cec3@canb.auug.org.au>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Pavel Tatashin <pasha.tatashin@oracle.com>, Kemi Wang <kemi.wang@intel.com>, David Rientjes <rientjes@google.com>, Jia He <jia.he@hxt-semitech.com>, Oscar Salvador <osalvador@suse.de>, Petr Tesarik <ptesarik@suse.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dan Williams <dan.j.williams@intel.com>, Mathieu Malaterre <malat@debian.org>, Baoquan He <bhe@redhat.com>, Wei Yang <richard.weiyang@gmail.com>, Ross Zwisler <zwisler@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

On 16.08.2018 13:44, Stephen Rothwell wrote:
> Hi David,
> 
> On Thu, 16 Aug 2018 12:06:24 +0200 David Hildenbrand <david@redhat.com> wrote:
>>
>> -static int __ref __offline_pages(unsigned long start_pfn,
>> -		  unsigned long end_pfn)
>> +/* Must be protected by mem_hotplug_begin() or a device_lock */
>> +int offline_pages(unsigned long start_pfn, unsigned long nr_pages)
> 
> You lose the __ref marking.  Does this introduce warnings since
> offline_pages() calls (at least) zone_pcp_update() which is marked
> __meminit.
> 

Good point, I'll recompile and in case there is a warning, keep the
__ref. Thanks!

-- 

Thanks,

David / dhildenb
