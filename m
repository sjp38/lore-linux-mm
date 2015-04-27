Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 2ABF86B006C
	for <linux-mm@kvack.org>; Mon, 27 Apr 2015 19:03:51 -0400 (EDT)
Received: by pacwv17 with SMTP id wv17so122401060pac.0
        for <linux-mm@kvack.org>; Mon, 27 Apr 2015 16:03:50 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id g2si31812490pdp.243.2015.04.27.16.03.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Apr 2015 16:03:50 -0700 (PDT)
Date: Mon, 27 Apr 2015 16:03:48 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCHv5 00/28] THP refcounting redesign
Message-Id: <20150427160348.fa3aefc5fc557e429d6b0295@linux-foundation.org>
In-Reply-To: <1429823043-157133-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1429823043-157133-1-git-send-email-kirill.shutemov@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 24 Apr 2015 00:03:35 +0300 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:

> Hello everybody,
> 
> Here's reworked version of my patchset. All known issues were addressed.
> 
> The goal of patchset is to make refcounting on THP pages cheaper with
> simpler semantics and allow the same THP compound page to be mapped with
> PMD and PTEs. This is required to get reasonable THP-pagecache
> implementation.

Are there any measurable performance improvements?

> With the new refcounting design it's much easier to protect against
> split_huge_page(): simple reference on a page will make you the deal.
> It makes gup_fast() implementation simpler and doesn't require
> special-case in futex code to handle tail THP pages.
> 
> It should improve THP utilization over the system since splitting THP in
> one process doesn't necessary lead to splitting the page in all other
> processes have the page mapped.
> 
> The patchset drastically lower complexity of get_page()/put_page()
> codepaths. I encourage reviewers look on this code before-and-after to
> justify time budget on reviewing this patchset.
>
> ...
>
>  59 files changed, 1144 insertions(+), 1509 deletions(-)

It's huge.  I'm going to need help reviewing this.  Have earlier
versions been reviewed much?  Who do you believe are suitable
reviewers?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
