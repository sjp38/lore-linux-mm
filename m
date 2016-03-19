Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 212AA828DF
	for <linux-mm@kvack.org>; Fri, 18 Mar 2016 21:02:43 -0400 (EDT)
Received: by mail-wm0-f54.google.com with SMTP id l124so48439782wmf.1
        for <linux-mm@kvack.org>; Fri, 18 Mar 2016 18:02:43 -0700 (PDT)
Received: from mail-wm0-x230.google.com (mail-wm0-x230.google.com. [2a00:1450:400c:c09::230])
        by mx.google.com with ESMTPS id i185si1217458wmi.55.2016.03.18.18.02.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Mar 2016 18:02:42 -0700 (PDT)
Received: by mail-wm0-x230.google.com with SMTP id l68so58211306wml.1
        for <linux-mm@kvack.org>; Fri, 18 Mar 2016 18:02:42 -0700 (PDT)
Date: Sat, 19 Mar 2016 04:02:40 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv4 08/25] thp: support file pages in zap_huge_pmd()
Message-ID: <20160319010239.GB29883@node.shutemov.name>
References: <1457737157-38573-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1457737157-38573-9-git-send-email-kirill.shutemov@linux.intel.com>
 <87a8lvao4a.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87a8lvao4a.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Fri, Mar 18, 2016 at 07:23:41PM +0530, Aneesh Kumar K.V wrote:
> "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> writes:
> 
> > [ text/plain ]
> > split_huge_pmd() for file mappings (and DAX too) is implemented by just
> > clearing pmd entry as we can re-fill this area from page cache on pte
> > level later.
> >
> > This means we don't need deposit page tables when file THP is mapped.
> > Therefore we shouldn't try to withdraw a page table on zap_huge_pmd()
> > file THP PMD.
> 
> Archs like ppc64 use deposited page table to track the hardware page
> table slot information. We probably may want to add hooks which arch can
> use to achieve the same even with file THP 

Could you describe more on what kind of information you're talking about?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
