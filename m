Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id B73EE6B0073
	for <linux-mm@kvack.org>; Thu, 27 Feb 2014 17:08:29 -0500 (EST)
Received: by mail-wg0-f46.google.com with SMTP id z12so3493203wgg.5
        for <linux-mm@kvack.org>; Thu, 27 Feb 2014 14:08:29 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id kr10si5550808wjc.156.2014.02.27.14.08.27
        for <linux-mm@kvack.org>;
        Thu, 27 Feb 2014 14:08:28 -0800 (PST)
Date: Thu, 27 Feb 2014 17:08:21 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <530fb75c.aacbc20a.1fd9.fffffe05SMTPIN_ADDED_BROKEN@mx.google.com>
In-Reply-To: <20140227132350.9378977e0ccbb3a7cf74ee18@linux-foundation.org>
References: <1393475977-3381-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1393475977-3381-4-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20140227132350.9378977e0ccbb3a7cf74ee18@linux-foundation.org>
Subject: Re: [PATCH 3/3] mm: call vma_adjust_trans_huge() only for thp-enabled
 vma
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: sasha.levin@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Feb 27, 2014 at 01:23:50PM -0800, Andrew Morton wrote:
> On Wed, 26 Feb 2014 23:39:37 -0500 Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:
> 
> > vma_adjust() is called also for vma(VM_HUGETLB) and it could happen that
> > we happen to try to split hugetlbfs hugepage. So exclude the possibility.
> > 
> 
> It would be nice to have a more complete changelog here please.  Under
> what circumstances does this cause problems and what are the
> user-observable effects?

I have no user-visible problem.
This is a kind of precaution to confirm that transparent hugepage code
should not be called for hugetlbfs workload.
.. but I think that this patch doesn't work as I intended because
transparent_hugepage_enabled() can return true for vma(VM_HUGETLB).
So I separate out this patch from this series for now.

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
