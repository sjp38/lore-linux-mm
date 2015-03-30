Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id DA8D06B0032
	for <linux-mm@kvack.org>; Mon, 30 Mar 2015 10:10:41 -0400 (EDT)
Received: by pddn5 with SMTP id n5so60822400pdd.2
        for <linux-mm@kvack.org>; Mon, 30 Mar 2015 07:10:41 -0700 (PDT)
Received: from e28smtp02.in.ibm.com (e28smtp02.in.ibm.com. [122.248.162.2])
        by mx.google.com with ESMTPS id jp11si12099145pbb.255.2015.03.30.07.10.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 30 Mar 2015 07:10:40 -0700 (PDT)
Received: from /spool/local
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 30 Mar 2015 19:40:36 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 9E70AE0056
	for <linux-mm@kvack.org>; Mon, 30 Mar 2015 19:42:52 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay05.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t2UEAVMn33685538
	for <linux-mm@kvack.org>; Mon, 30 Mar 2015 19:40:33 +0530
Received: from d28av02.in.ibm.com (localhost [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t2UDxQP5019317
	for <linux-mm@kvack.org>; Mon, 30 Mar 2015 19:29:27 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCHv4 18/24] thp, mm: split_huge_page(): caller need to lock page
In-Reply-To: <1425486792-93161-19-git-send-email-kirill.shutemov@linux.intel.com>
References: <1425486792-93161-1-git-send-email-kirill.shutemov@linux.intel.com> <1425486792-93161-19-git-send-email-kirill.shutemov@linux.intel.com>
Date: Mon, 30 Mar 2015 19:40:29 +0530
Message-ID: <87mw2ulgoa.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> writes:

> We're going to use migration entries instead of compound_lock() to
> stabilize page refcounts. Setup and remove migration entries require
> page to be locked.
>
> Some of split_huge_page() callers already have the page locked. Let's
> require everybody to lock the page before calling split_huge_page().
>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Why not have split_huge_page_locked/unlocked, and call the one which
takes lock internally every where ?

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
