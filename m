Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 335AA6B0032
	for <linux-mm@kvack.org>; Fri, 15 May 2015 10:57:42 -0400 (EDT)
Received: by pacwv17 with SMTP id wv17so14732105pac.2
        for <linux-mm@kvack.org>; Fri, 15 May 2015 07:57:41 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id az16si2941378pdb.129.2015.05.15.07.57.41
        for <linux-mm@kvack.org>;
        Fri, 15 May 2015 07:57:41 -0700 (PDT)
Message-ID: <55560963.30106@intel.com>
Date: Fri, 15 May 2015 07:57:39 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCHv5 03/28] memcg: adjust to support new THP refcounting
References: <1429823043-157133-1-git-send-email-kirill.shutemov@linux.intel.com> <1429823043-157133-4-git-send-email-kirill.shutemov@linux.intel.com> <5555A3D1.3010108@suse.cz> <20150515111828.GC6250@node.dhcp.inet.fi>
In-Reply-To: <20150515111828.GC6250@node.dhcp.inet.fi>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Vlastimil Babka <vbabka@suse.cz>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 05/15/2015 04:18 AM, Kirill A. Shutemov wrote:
>> > But same question about whether it should be using hpage_nr_pages() instead
>> > of a constant.
> No. Compiler woundn't be able to optimize HPAGE_PMD_NR away for THP=n,
> since compound value cross compilation unit barrier.

What code are you talking about here, specifically?  This?

static inline int hpage_nr_pages(struct page *page)
{
        if (unlikely(PageTransHuge(page)))
                return HPAGE_PMD_NR;
        return 1;
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
