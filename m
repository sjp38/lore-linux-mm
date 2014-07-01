Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 0E7896B0031
	for <linux-mm@kvack.org>; Tue,  1 Jul 2014 17:00:40 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id kq14so11183907pab.6
        for <linux-mm@kvack.org>; Tue, 01 Jul 2014 14:00:40 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id le9si28087955pab.198.2014.07.01.14.00.39
        for <linux-mm@kvack.org>;
        Tue, 01 Jul 2014 14:00:39 -0700 (PDT)
Message-ID: <53B32170.1040707@intel.com>
Date: Tue, 01 Jul 2014 14:00:32 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 11/13] mempolicy: apply page table walker on queue_pages_range()
References: <1404234451-21695-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1404234451-21695-12-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1404234451-21695-12-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>, Jet Chen <jet.chen@intel.com>

On 07/01/2014 10:07 AM, Naoya Horiguchi wrote:
> queue_pages_range() does page table walking in its own way now, but there
> is some code duplicate. This patch applies page table walker to reduce
> lines of code.
> 
> queue_pages_range() has to do some precheck to determine whether we really
> walk over the vma or just skip it. Now we have test_walk() callback in
> mm_walk for this purpose, so we can do this replacement cleanly.
> queue_pages_test_walk() depends on not only the current vma but also the
> previous one, so queue_pages->prev is introduced to remember it.

Hi Naoya,

The previous version of this patch caused a performance regression which
was reported to you:

	http://marc.info/?l=linux-kernel&m=140375975525069&w=2

Has that been dealt with in this version somehow?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
