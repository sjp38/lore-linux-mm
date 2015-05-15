Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 0EBC86B006E
	for <linux-mm@kvack.org>; Fri, 15 May 2015 08:01:45 -0400 (EDT)
Received: by wgin8 with SMTP id n8so110494655wgi.0
        for <linux-mm@kvack.org>; Fri, 15 May 2015 05:01:44 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id pi9si2942924wic.96.2015.05.15.05.01.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 15 May 2015 05:01:43 -0700 (PDT)
Message-ID: <5555E024.6060309@suse.cz>
Date: Fri, 15 May 2015 14:01:40 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCHv5 05/28] mm: adjust FOLL_SPLIT for new refcounting
References: <1429823043-157133-1-git-send-email-kirill.shutemov@linux.intel.com> <1429823043-157133-6-git-send-email-kirill.shutemov@linux.intel.com> <5555D2F7.5070301@suse.cz> <20150515113646.GE6250@node.dhcp.inet.fi>
In-Reply-To: <20150515113646.GE6250@node.dhcp.inet.fi>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 05/15/2015 01:36 PM, Kirill A. Shutemov wrote:
> On Fri, May 15, 2015 at 01:05:27PM +0200, Vlastimil Babka wrote:
>> On 04/23/2015 11:03 PM, Kirill A. Shutemov wrote:
>>> We need to prepare kernel to allow transhuge pages to be mapped with
>>> ptes too. We need to handle FOLL_SPLIT in follow_page_pte().
>>>
>>> Also we use split_huge_page() directly instead of split_huge_page_pmd().
>>> split_huge_page_pmd() will gone.
>>
>> You still call split_huge_page_pmd() for the is_huge_zero_page(page) case.
>
> For huge zero page we split PMD into table of zero pages and don't touch
> compound page under it. That's what split_huge_page_pmd() (renamed into
> split_huge_pmd()) will do by the end of patchset.

Ah, I see.

>> Also, of the code around split_huge_page() you basically took from
>> split_huge_page_pmd() and open-coded into follow_page_mask(), you didn't
>> include the mmu notifier calls. Why are they needed in split_huge_page_pmd()
>> but not here?
>
> We do need mmu notifier in split_huge_page_pmd() for huge zero page. When

Oh, I guess that's obvious then... to someone, anyway. Thanks.

In that case the patch seems fine.

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> we need to split compound page we go into split_huge_page() which takes
> care about mmut notifiers.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
