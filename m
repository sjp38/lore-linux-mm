Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id A12F36B0032
	for <linux-mm@kvack.org>; Thu, 30 Apr 2015 07:52:28 -0400 (EDT)
Received: by wgin8 with SMTP id n8so59374274wgi.0
        for <linux-mm@kvack.org>; Thu, 30 Apr 2015 04:52:28 -0700 (PDT)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.195])
        by mx.google.com with ESMTP id e10si3568700wjq.166.2015.04.30.04.52.26
        for <linux-mm@kvack.org>;
        Thu, 30 Apr 2015 04:52:26 -0700 (PDT)
Date: Thu, 30 Apr 2015 14:52:10 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv5 02/28] rmap: add argument to charge compound page
Message-ID: <20150430115210.GA15874@node.dhcp.inet.fi>
References: <1429823043-157133-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1429823043-157133-3-git-send-email-kirill.shutemov@linux.intel.com>
 <5540FE60.8010802@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5540FE60.8010802@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Marchand <jmarchan@redhat.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Apr 29, 2015 at 05:53:04PM +0200, Jerome Marchand wrote:
> On 04/23/2015 11:03 PM, Kirill A. Shutemov wrote:
> > diff --git a/mm/rmap.c b/mm/rmap.c
> > index dad23a43e42c..4ca4b5cffd95 100644
> > --- a/mm/rmap.c
> > +++ b/mm/rmap.c
> > @@ -1048,9 +1048,9 @@ static void __page_check_anon_rmap(struct page *page,
> >   * (but PageKsm is never downgraded to PageAnon).
> >   */
> 
> The comment above should be updated to include the new argument.
> 
...
> > @@ -1097,15 +1101,18 @@ void do_page_add_anon_rmap(struct page *page,
> >   * Page does not have to be locked.
> >   */
> 
> Again, the description of the function should be updated.
> 
...
> > @@ -1161,9 +1168,12 @@ out:
> >   *
> >   * The caller needs to hold the pte lock.
> >   */
> 
> Same here.

Will be fixed for v6. Thanks.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
