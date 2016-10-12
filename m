Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5C9A26B025E
	for <linux-mm@kvack.org>; Wed, 12 Oct 2016 05:59:34 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id f6so32838063qtd.4
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 02:59:34 -0700 (PDT)
Received: from sender153-mail.zoho.com (sender153-mail.zoho.com. [74.201.84.153])
        by mx.google.com with ESMTPS id g96si3426618qkh.331.2016.10.12.02.59.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 12 Oct 2016 02:59:33 -0700 (PDT)
Subject: Re: [RFC PATCH 1/1] mm/percpu.c: fix memory leakage issue when
 allocate a odd alignment area
References: <bc3126cd-226d-91c7-d323-48881095accf@zoho.com>
 <20161011172228.GA30403@dhcp22.suse.cz>
 <7649b844-cfe6-abce-148e-1e2236e7d443@zoho.com>
 <20161012065332.GA9504@dhcp22.suse.cz> <57FDE531.7060003@zoho.com>
 <20161012082538.GC17128@dhcp22.suse.cz> <57FDF7EF.6070606@zoho.com>
 <20161012095439.GI17128@dhcp22.suse.cz>
From: zijun_hu <zijun_hu@zoho.com>
Message-ID: <57FE0969.8080002@zoho.com>
Date: Wed, 12 Oct 2016 17:59:05 +0800
MIME-Version: 1.0
In-Reply-To: <20161012095439.GI17128@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, zijun_hu@htc.com, tj@kernel.org, akpm@linux-foundation.org, cl@linux.com

On 10/12/2016 05:54 PM, Michal Hocko wrote:
> On Wed 12-10-16 16:44:31, zijun_hu wrote:
>> On 10/12/2016 04:25 PM, Michal Hocko wrote:
>>> On Wed 12-10-16 15:24:33, zijun_hu wrote:
> [...]
>>>> i found the following code segments in mm/vmalloc.c
>>>> static struct vmap_area *alloc_vmap_area(unsigned long size,
>>>>                                 unsigned long align,
>>>>                                 unsigned long vstart, unsigned long vend,
>>>>                                 int node, gfp_t gfp_mask)
>>>> {
>>>> ...
>>>>
>>>>         BUG_ON(!size);
>>>>         BUG_ON(offset_in_page(size));
>>>>         BUG_ON(!is_power_of_2(align));
>>>
>>> See a recent Linus rant about BUG_ONs. These BUG_ONs are quite old and
>>> from a quick look they are even unnecessary. So rather than adding more
>>> of those, I think removing those that are not needed is much more
>>> preferred.
>>>
>> i notice that, and the above code segments is used to illustrate that
>> input parameter checking is necessary sometimes
> 
> Why do you think it is necessary here?
> 
i am sorry for reply late
i don't know whether it is necessary
i just find there are so many sanity checkup in current internal interfaces

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
