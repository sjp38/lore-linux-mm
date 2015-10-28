Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f177.google.com (mail-qk0-f177.google.com [209.85.220.177])
	by kanga.kvack.org (Postfix) with ESMTP id 2AD0C82F64
	for <linux-mm@kvack.org>; Wed, 28 Oct 2015 13:08:42 -0400 (EDT)
Received: by qkcl124 with SMTP id l124so2742408qkc.3
        for <linux-mm@kvack.org>; Wed, 28 Oct 2015 10:08:42 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j11si15698870qgj.128.2015.10.28.10.08.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Oct 2015 10:08:41 -0700 (PDT)
Date: Wed, 28 Oct 2015 17:08:36 +0000
From: Aaron Tomlin <atomlin@redhat.com>
Subject: Re: [PATCH] thp: Remove unused vma parameter from
 khugepaged_alloc_page
Message-ID: <20151028170836.GA18188@atomlin.usersys.redhat.com>
References: <1446051905-21828-1-git-send-email-atomlin@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1446051905-21828-1-git-send-email-atomlin@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: riel@redhat.com, lwoodman@redhat.com, aarcange@redhat.com, kirill.shutemov@linux.intel.com, mgorman@suse.de, vbabka@suse.cz, willy@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 2015-10-28 17:05 +0000, Aaron Tomlin wrote:
> The "vma" parameter to khugepaged_alloc_page() is unused.
> It has to remain unused or the drop read lock 'map_sem' optimisation
> introduce by commit 8b1645685acf ("thp: introduce khugepaged_prealloc_page
> and khugepaged_alloc_page") wouldn't be possible. So let's remove it.

Self nack due to incorrect commit message.

-- 
Aaron Tomlin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
