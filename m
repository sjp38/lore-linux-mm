Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id 9D52E6B0036
	for <linux-mm@kvack.org>; Mon, 28 Jul 2014 22:02:51 -0400 (EDT)
Received: by mail-qg0-f49.google.com with SMTP id j107so9559607qga.8
        for <linux-mm@kvack.org>; Mon, 28 Jul 2014 19:02:51 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o8si35065730qai.119.2014.07.28.19.02.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jul 2014 19:02:51 -0700 (PDT)
Date: Mon, 28 Jul 2014 21:10:18 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 2/3] mm/hugetlb: take refcount under page table lock in
 follow_huge_pmd()
Message-ID: <20140729011018.GA25865@nhori.redhat.com>
References: <1406570911-28133-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1406570911-28133-2-git-send-email-n-horiguchi@ah.jp.nec.com>
 <alpine.DEB.2.02.1407281602050.8998@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1407281602050.8998@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Mon, Jul 28, 2014 at 04:02:31PM -0700, David Rientjes wrote:
> On Mon, 28 Jul 2014, Naoya Horiguchi wrote:
> 
> > We have a race condition between move_pages() and freeing hugepages,
> > where move_pages() calls follow_page(FOLL_GET) for hugepages internally
> > and tries to get its refcount without preventing concurrent freeing.
> > This race crashes the kernel, so this patch fixes it by moving FOLL_GET
> > code for hugepages into follow_huge_pmd() with taking the page table lock.
> > 
> 
> What about CONFIG_ARCH_WANT_GENERAL_HUGETLB=n configs?

Ah yes, I need cover them.
So I'll add some wrapper to do this locking in common hugetlb code.

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
