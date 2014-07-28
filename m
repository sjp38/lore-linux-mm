Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f174.google.com (mail-ig0-f174.google.com [209.85.213.174])
	by kanga.kvack.org (Postfix) with ESMTP id A07066B0036
	for <linux-mm@kvack.org>; Mon, 28 Jul 2014 18:55:27 -0400 (EDT)
Received: by mail-ig0-f174.google.com with SMTP id c1so4488795igq.1
        for <linux-mm@kvack.org>; Mon, 28 Jul 2014 15:55:27 -0700 (PDT)
Received: from mail-ie0-x22b.google.com (mail-ie0-x22b.google.com [2607:f8b0:4001:c03::22b])
        by mx.google.com with ESMTPS id zb10si42421469icb.82.2014.07.28.15.55.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 28 Jul 2014 15:55:25 -0700 (PDT)
Received: by mail-ie0-f171.google.com with SMTP id at1so7514373iec.2
        for <linux-mm@kvack.org>; Mon, 28 Jul 2014 15:55:25 -0700 (PDT)
Date: Mon, 28 Jul 2014 15:55:22 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/3] mm/hugetlb: replace parameters of
 follow_huge_pmd/pud()
In-Reply-To: <1406570911-28133-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Message-ID: <alpine.DEB.2.02.1407281555100.8998@chino.kir.corp.google.com>
References: <1406570911-28133-1-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Mon, 28 Jul 2014, Naoya Horiguchi wrote:

> Currently follow_huge_pmd() and follow_huge_pud() don't use the parameter
> mm or write. So let's change these to vma and flags as a preparation for
> the next patch. No behavioral change.
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
