Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f173.google.com (mail-lb0-f173.google.com [209.85.217.173])
	by kanga.kvack.org (Postfix) with ESMTP id 6DEFC6B0072
	for <linux-mm@kvack.org>; Thu, 27 Feb 2014 17:56:08 -0500 (EST)
Received: by mail-lb0-f173.google.com with SMTP id p9so2149943lbv.4
        for <linux-mm@kvack.org>; Thu, 27 Feb 2014 14:56:07 -0800 (PST)
Received: from jenni2.inet.fi (mta-out.inet.fi. [195.156.147.13])
        by mx.google.com with ESMTP id jn5si1430188lbc.6.2014.02.27.14.56.06
        for <linux-mm@kvack.org>;
        Thu, 27 Feb 2014 14:56:06 -0800 (PST)
Date: Fri, 28 Feb 2014 00:56:00 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 3/3] mm: call vma_adjust_trans_huge() only for
 thp-enabled vma
Message-ID: <20140227225600.GA8034@node.dhcp.inet.fi>
References: <1393475977-3381-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1393475977-3381-4-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1393475977-3381-4-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Feb 26, 2014 at 11:39:37PM -0500, Naoya Horiguchi wrote:
> vma_adjust() is called also for vma(VM_HUGETLB) and it could happen that
> we happen to try to split hugetlbfs hugepage. So exclude the possibility.

NAK.

It can't happen: vma_adjust_trans_huge checks for vma->vm_ops and hugetlb
VMA always have it set unlike THP.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
