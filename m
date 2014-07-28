Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f172.google.com (mail-ig0-f172.google.com [209.85.213.172])
	by kanga.kvack.org (Postfix) with ESMTP id D52956B0036
	for <linux-mm@kvack.org>; Mon, 28 Jul 2014 19:02:34 -0400 (EDT)
Received: by mail-ig0-f172.google.com with SMTP id h15so4496696igd.5
        for <linux-mm@kvack.org>; Mon, 28 Jul 2014 16:02:34 -0700 (PDT)
Received: from mail-ig0-x230.google.com (mail-ig0-x230.google.com [2607:f8b0:4001:c05::230])
        by mx.google.com with ESMTPS id jr8si44444790icc.62.2014.07.28.16.02.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 28 Jul 2014 16:02:34 -0700 (PDT)
Received: by mail-ig0-f176.google.com with SMTP id hn18so4490325igb.3
        for <linux-mm@kvack.org>; Mon, 28 Jul 2014 16:02:33 -0700 (PDT)
Date: Mon, 28 Jul 2014 16:02:31 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/3] mm/hugetlb: take refcount under page table lock in
 follow_huge_pmd()
In-Reply-To: <1406570911-28133-2-git-send-email-n-horiguchi@ah.jp.nec.com>
Message-ID: <alpine.DEB.2.02.1407281602050.8998@chino.kir.corp.google.com>
References: <1406570911-28133-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1406570911-28133-2-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Mon, 28 Jul 2014, Naoya Horiguchi wrote:

> We have a race condition between move_pages() and freeing hugepages,
> where move_pages() calls follow_page(FOLL_GET) for hugepages internally
> and tries to get its refcount without preventing concurrent freeing.
> This race crashes the kernel, so this patch fixes it by moving FOLL_GET
> code for hugepages into follow_huge_pmd() with taking the page table lock.
> 

What about CONFIG_ARCH_WANT_GENERAL_HUGETLB=n configs?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
