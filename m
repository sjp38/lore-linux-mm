Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 818F04403D8
	for <linux-mm@kvack.org>; Fri,  5 Feb 2016 06:52:22 -0500 (EST)
Received: by mail-wm0-f45.google.com with SMTP id r129so23232116wmr.0
        for <linux-mm@kvack.org>; Fri, 05 Feb 2016 03:52:22 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m80si14076412wmd.112.2016.02.05.03.52.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 05 Feb 2016 03:52:21 -0800 (PST)
Subject: Re: [PATCH] mm/hugetlb: fix gigantic page initialization/allocation
References: <1454452420-25007-1-git-send-email-mike.kravetz@oracle.com>
 <alpine.DEB.2.10.1602021457500.9118@chino.kir.corp.google.com>
 <56B138F6.70704@oracle.com>
 <20160203030137.GA22446@hori1.linux.bs1.fc.nec.co.jp>
 <56B17ED2.2070205@oracle.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56B48CF1.1040103@suse.cz>
Date: Fri, 5 Feb 2016 12:52:17 +0100
MIME-Version: 1.0
In-Reply-To: <56B17ED2.2070205@oracle.com>
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Jerome Marchand <jmarchan@redhat.com>, Michal Hocko <mhocko@suse.cz>

On 02/03/2016 05:15 AM, Mike Kravetz wrote:
> On 02/02/2016 07:01 PM, Naoya Horiguchi wrote:
>> On Tue, Feb 02, 2016 at 03:17:10PM -0800, Mike Kravetz wrote:
>>> I agree.  Naoya did debug and provide fix via e-mail exchange.  He did not
>>> sign-off and I could not tell if he was going to pursue.  My only intention
>>> was to fix ASAP.
>>>
>>> More than happy to give Naoya credit.
>>
>> Thank you! It's great if you append my signed-off below yours.
>>
>> Naoya
> 
> Adding Naoya's sign off and Acks received
> 
> mm/hugetlb: fix gigantic page initialization/allocation
> 
> Attempting to preallocate 1G gigantic huge pages at boot time with
> "hugepagesz=1G hugepages=1" on the kernel command line will prevent
> booting with the following:
> 
> kernel BUG at mm/hugetlb.c:1218!
> 
> When mapcount accounting was reworked, the setting of compound_mapcount_ptr
> in prep_compound_gigantic_page was overlooked.  As a result, the validation
> of mapcount in free_huge_page fails.
> 
> The "BUG_ON" checks in free_huge_page were also changed to "VM_BUG_ON_PAGE"
> to assist with debugging.
> 
> Fixes: af5642a8af ("mm: rework mapcount accounting to enable 4k mapping
> of THPs")
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Acked-by: David Rientjes <rientjes@google.com>

Tested-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
