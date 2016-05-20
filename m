Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6274D6B0253
	for <linux-mm@kvack.org>; Fri, 20 May 2016 06:33:24 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id a17so50737493wme.1
        for <linux-mm@kvack.org>; Fri, 20 May 2016 03:33:24 -0700 (PDT)
Received: from mail-lb0-x244.google.com (mail-lb0-x244.google.com. [2a00:1450:4010:c04::244])
        by mx.google.com with ESMTPS id ml3si18104470lbc.61.2016.05.20.03.33.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 May 2016 03:33:23 -0700 (PDT)
Received: by mail-lb0-x244.google.com with SMTP id bg8so5341622lbc.1
        for <linux-mm@kvack.org>; Fri, 20 May 2016 03:33:23 -0700 (PDT)
Date: Fri, 20 May 2016 13:33:19 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv8 26/32] thp: update Documentation/vm/transhuge.txt
Message-ID: <20160520103319.GA4269@node.shutemov.name>
References: <1463067672-134698-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1463067672-134698-27-git-send-email-kirill.shutemov@linux.intel.com>
 <573DE7B1.4040303@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <573DE7B1.4040303@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Julien Grall <julien.grall@arm.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, Andres Lagar-Cavilla <andreslc@google.com>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Steve Capper <Steve.Capper@arm.com>

On Thu, May 19, 2016 at 05:20:01PM +0100, Julien Grall wrote:
> Hello Kirill,
> 
> On 12/05/16 16:41, Kirill A. Shutemov wrote:
> >Add info about tmpfs/shmem with huge pages.
> >
> >Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> >---
> >  Documentation/vm/transhuge.txt | 130 +++++++++++++++++++++++++++++------------
> >  1 file changed, 93 insertions(+), 37 deletions(-)
> >
> >diff --git a/Documentation/vm/transhuge.txt b/Documentation/vm/transhuge.txt
> >index d9cb65cf5cfd..96a49f123cac 100644
> >--- a/Documentation/vm/transhuge.txt
> >+++ b/Documentation/vm/transhuge.txt
> >@@ -9,8 +9,8 @@ using huge pages for the backing of virtual memory with huge pages
> >  that supports the automatic promotion and demotion of page sizes and
> >  without the shortcomings of hugetlbfs.
> >
> >-Currently it only works for anonymous memory mappings but in the
> >-future it can expand over the pagecache layer starting with tmpfs.
> >+Currently it only works for anonymous memory mappings and tmpfs/shmem.
> >+But in the future it can expand to other filesystems.
> >
> >  The reason applications are running faster is because of two
> >  factors. The first factor is almost completely irrelevant and it's not
> >@@ -48,7 +48,7 @@ miss is going to run faster.
> >  - if some task quits and more hugepages become available (either
> >    immediately in the buddy or through the VM), guest physical memory
> >    backed by regular pages should be relocated on hugepages
> >-  automatically (with khugepaged)
> >+  automatically (with khugepaged, limited to anonymous huge pages for now)
> 
> Is it still relevant? I think the patch #30 at the support for tmpfs/shmem.

I forgot to update documentation. I'll do for the next round when rebase
to v4.7-rc1.

Thanks for noticing this.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
