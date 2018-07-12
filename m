Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 145F76B0271
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 19:45:40 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id v25-v6so11289234pfm.11
        for <linux-mm@kvack.org>; Thu, 12 Jul 2018 16:45:40 -0700 (PDT)
Received: from out4437.biz.mail.alibaba.com (out4437.biz.mail.alibaba.com. [47.88.44.37])
        by mx.google.com with ESMTPS id x19-v6si21624760pgk.80.2018.07.12.16.45.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jul 2018 16:45:39 -0700 (PDT)
Subject: Re: [RFC v4 0/3] mm: zap pages with read mmap_sem in munmap for large
 mapping
References: <1531265649-93433-1-git-send-email-yang.shi@linux.alibaba.com>
 <20180711111052.hbyukcwetmjjpij2@kshutemo-mobl1>
 <3d4c69c9-dd2b-30d2-5bf2-d5b108a76758@linux.alibaba.com>
 <20180712080418.GC32648@dhcp22.suse.cz>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <f47b5a41-3fb1-ac81-1ead-78e4ac5fae51@linux.alibaba.com>
Date: Thu, 12 Jul 2018 16:45:18 -0700
MIME-Version: 1.0
In-Reply-To: <20180712080418.GC32648@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, willy@infradead.org, ldufour@linux.vnet.ibm.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 7/12/18 1:04 AM, Michal Hocko wrote:
> On Wed 11-07-18 10:04:48, Yang Shi wrote:
> [...]
>> One approach is to save all the vmas on a separate list, then zap_page_range
>> does unmap with this list.
> Just detached unmapped vma chain from mm. You can keep the existing
> vm_next chain and reuse it.

Yes. Other than this, we still need do:

 A  * Tell zap_page_range not update vm_flags as what I did in v4. Of 
course without VM_DEAD this time

 A  * Extract pagetable free code then do it after zap_page_range. I 
think I can just cal free_pgd_range() directly.

>
