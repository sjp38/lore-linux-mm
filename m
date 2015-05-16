Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id A80DD6B0075
	for <linux-mm@kvack.org>; Sat, 16 May 2015 19:17:53 -0400 (EDT)
Received: by wguv19 with SMTP id v19so89066018wgu.1
        for <linux-mm@kvack.org>; Sat, 16 May 2015 16:17:53 -0700 (PDT)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.203])
        by mx.google.com with ESMTP id eh5si10042620wjd.174.2015.05.16.16.17.51
        for <linux-mm@kvack.org>;
        Sat, 16 May 2015 16:17:52 -0700 (PDT)
Date: Sun, 17 May 2015 02:17:32 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv5 03/28] memcg: adjust to support new THP refcounting
Message-ID: <20150516231732.GA13265@node.dhcp.inet.fi>
References: <1429823043-157133-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1429823043-157133-4-git-send-email-kirill.shutemov@linux.intel.com>
 <5555A3D1.3010108@suse.cz>
 <20150515111828.GC6250@node.dhcp.inet.fi>
 <55560963.30106@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55560963.30106@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, May 15, 2015 at 07:57:39AM -0700, Dave Hansen wrote:
> On 05/15/2015 04:18 AM, Kirill A. Shutemov wrote:
> >> > But same question about whether it should be using hpage_nr_pages() instead
> >> > of a constant.
> > No. Compiler woundn't be able to optimize HPAGE_PMD_NR away for THP=n,
> > since compound value cross compilation unit barrier.
> 
> What code are you talking about here, specifically?  This?
> 
> static inline int hpage_nr_pages(struct page *page)
> {
>         if (unlikely(PageTransHuge(page)))
>                 return HPAGE_PMD_NR;
>         return 1;
> }

No. See for instance mem_cgroup_try_charge(). Vlastimil would like to
replace hpage_nr_pages() call with plain HPAGE_PMD_NR.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
