Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id AB39A6B025A
	for <linux-mm@kvack.org>; Mon,  3 Aug 2015 06:44:50 -0400 (EDT)
Received: by wibud3 with SMTP id ud3so108069117wib.0
        for <linux-mm@kvack.org>; Mon, 03 Aug 2015 03:44:50 -0700 (PDT)
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com. [209.85.212.171])
        by mx.google.com with ESMTPS id bp4si24761641wjb.14.2015.08.03.03.44.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Aug 2015 03:44:49 -0700 (PDT)
Received: by wibud3 with SMTP id ud3so130372330wib.1
        for <linux-mm@kvack.org>; Mon, 03 Aug 2015 03:44:48 -0700 (PDT)
Date: Mon, 3 Aug 2015 13:44:46 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv9 29/36] thp: implement split_huge_pmd()
Message-ID: <20150803104446.GC25034@node.dhcp.inet.fi>
References: <1437402069-105900-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1437402069-105900-30-git-send-email-kirill.shutemov@linux.intel.com>
 <55BB8F0F.8040903@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55BB8F0F.8040903@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Marchand <jmarchan@redhat.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Jul 31, 2015 at 05:06:55PM +0200, Jerome Marchand wrote:
> On 07/20/2015 04:21 PM, Kirill A. Shutemov wrote:
> > Original split_huge_page() combined two operations: splitting PMDs into
> > tables of PTEs and splitting underlying compound page. This patch
> > implements split_huge_pmd() which split given PMD without splitting
> > other PMDs this page mapped with or underlying compound page.
> > 
> > Without tail page refcounting, implementation of split_huge_pmd() is
> > pretty straight-forward.
> 
> While it's significantly simpler than it used to be, straight-forward is
> still not the adjective which come to my mind.

The commit message was written to older revision :-P

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
