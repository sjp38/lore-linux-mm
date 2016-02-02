Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f179.google.com (mail-ob0-f179.google.com [209.85.214.179])
	by kanga.kvack.org (Postfix) with ESMTP id 047866B0005
	for <linux-mm@kvack.org>; Tue,  2 Feb 2016 18:23:52 -0500 (EST)
Received: by mail-ob0-f179.google.com with SMTP id ba1so5721287obb.3
        for <linux-mm@kvack.org>; Tue, 02 Feb 2016 15:23:52 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id r7si4848675oew.52.2016.02.02.15.23.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Feb 2016 15:23:50 -0800 (PST)
Subject: Re: [PATCH] mm/hugetlb: fix gigantic page initialization/allocation
References: <1454452420-25007-1-git-send-email-mike.kravetz@oracle.com>
 <alpine.DEB.2.10.1602021457500.9118@chino.kir.corp.google.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <56B138F6.70704@oracle.com>
Date: Tue, 2 Feb 2016 15:17:10 -0800
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1602021457500.9118@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Jerome Marchand <jmarchan@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>

On 02/02/2016 02:59 PM, David Rientjes wrote:
> On Tue, 2 Feb 2016, Mike Kravetz wrote:
> 
>> Attempting to preallocate 1G gigantic huge pages at boot time with
>> "hugepagesz=1G hugepages=1" on the kernel command line will prevent
>> booting with the following:
>>
>> kernel BUG at mm/hugetlb.c:1218!
>>
>> When mapcount accounting was reworked, the setting of compound_mapcount_ptr
>> in prep_compound_gigantic_page was overlooked.  As a result, the validation
>> of mapcount in free_huge_page fails.
>>
>> The "BUG_ON" checks in free_huge_page were also changed to "VM_BUG_ON_PAGE"
>> to assist with debugging.
>>
>> Fixes: af5642a8af ("mm: rework mapcount accounting to enable 4k mapping of THPs")
>> Suggested-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
> 
> I'm not sure whether this should have a "From: Naoya Horiguchi" line with 
> an accompanying sign-off or not, since Naoya debugged and wrote the actual 
> fix to prep_compound_gigantic_page().

I agree.  Naoya did debug and provide fix via e-mail exchange.  He did not
sign-off and I could not tell if he was going to pursue.  My only intention
was to fix ASAP.

More than happy to give Naoya credit.
-- 
Mike Kravetz

> 
> Acked-by: David Rientjes <rientjes@google.com>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
