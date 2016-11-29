Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5F6266B0038
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 05:44:28 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id u144so43285347wmu.1
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 02:44:28 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f127si1868936wmf.124.2016.11.29.02.44.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 29 Nov 2016 02:44:26 -0800 (PST)
Subject: Re: [PATCH v2 1/6] mm: hugetlb: rename some allocation functions
References: <1479107259-2011-1-git-send-email-shijie.huang@arm.com>
 <1479107259-2011-2-git-send-email-shijie.huang@arm.com>
 <52b661c9-f4b0-3d94-cf9b-a0ffd5ecb723@suse.cz>
 <20161129085349.GA16569@sha-win-210.asiapac.arm.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <d28b825d-1026-1e91-fa4e-395df3e1be86@suse.cz>
Date: Tue, 29 Nov 2016 11:44:23 +0100
MIME-Version: 1.0
In-Reply-To: <20161129085349.GA16569@sha-win-210.asiapac.arm.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Huang Shijie <shijie.huang@arm.com>
Cc: akpm@linux-foundation.org, catalin.marinas@arm.com, n-horiguchi@ah.jp.nec.com, mhocko@suse.com, kirill.shutemov@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, gerald.schaefer@de.ibm.com, mike.kravetz@oracle.com, linux-mm@kvack.org, will.deacon@arm.com, steve.capper@arm.com, kaly.xin@arm.com, nd@arm.com, linux-arm-kernel@lists.infradead.org

On 11/29/2016 09:53 AM, Huang Shijie wrote:
> On Mon, Nov 28, 2016 at 02:29:03PM +0100, Vlastimil Babka wrote:
>> On 11/14/2016 08:07 AM, Huang Shijie wrote:
>> >  static inline bool gigantic_page_supported(void) { return true; }
>> >  #else
>> > +static inline struct page *alloc_gigantic_page(int nid, unsigned int order)
>> > +{
>> > +	return NULL;
>> > +}
>>
>> This hunk is not explained by the description. Could belong to a later
>> patch?
>>
>
> Okay, I can create an extra patch to add the description for the
> alloc_gigantic_page().

Not sure about extra patch, just move it to an existing later patch that relies 
on it?

Vlastimil

> Thanks
> Huang Shijie
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
