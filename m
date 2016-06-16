Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 099F86B0253
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 04:02:54 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id a2so22062925lfe.0
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 01:02:53 -0700 (PDT)
Received: from mail-lf0-x241.google.com (mail-lf0-x241.google.com. [2a00:1450:4010:c07::241])
        by mx.google.com with ESMTPS id h6si3994585lbs.20.2016.06.16.01.02.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Jun 2016 01:02:52 -0700 (PDT)
Received: by mail-lf0-x241.google.com with SMTP id l188so4558484lfe.0
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 01:02:52 -0700 (PDT)
Date: Thu, 16 Jun 2016 11:02:49 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv9-rebased2 03/37] mm, thp: fix locking inconsistency in
 collapse_huge_page
Message-ID: <20160616080249.GA18137@node.shutemov.name>
References: <1465222029-45942-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1466021202-61880-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1466021202-61880-4-git-send-email-kirill.shutemov@linux.intel.com>
 <20160616004307.GA658@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160616004307.GA658@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, Andres Lagar-Cavilla <andreslc@google.com>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Stephen Rothwell <sfr@canb.auug.org.au>, Rik van Riel <riel@redhat.com>

On Thu, Jun 16, 2016 at 09:43:07AM +0900, Sergey Senozhatsky wrote:
> Hello,
> 
> On (06/15/16 23:06), Kirill A. Shutemov wrote:
> [..]
> > After creating revalidate vma function, locking inconsistency occured
> > due to directing the code path to wrong label. This patch directs
> > to correct label and fix the inconsistency.
> > 
> > Related commit that caused inconsistency:
> > http://git.kernel.org/cgit/linux/kernel/git/next/linux-next.git/commit/?id=da4360877094368f6dfe75bbe804b0f0a5d575b0
> 
> 
> as far as I remember, Vlastimil had "one more thing" to ask
> http://marc.info/?l=linux-mm&m=146521832732210&w=2
> 
> or is it safe?

As I mentioned in cover letter, 05/37 address the issue.

I didn't fold it in. It's up to Andrew.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
