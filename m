Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 9C05182F84
	for <linux-mm@kvack.org>; Mon, 19 Oct 2015 08:21:31 -0400 (EDT)
Received: by wijp11 with SMTP id p11so3096386wij.0
        for <linux-mm@kvack.org>; Mon, 19 Oct 2015 05:21:31 -0700 (PDT)
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com. [209.85.212.173])
        by mx.google.com with ESMTPS id dm12si21988647wid.39.2015.10.19.05.21.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Oct 2015 05:21:30 -0700 (PDT)
Received: by wicll6 with SMTP id ll6so2914631wic.1
        for <linux-mm@kvack.org>; Mon, 19 Oct 2015 05:21:30 -0700 (PDT)
Date: Mon, 19 Oct 2015 15:21:26 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: do not inc NR_PAGETABLE if ptlock_init failed
Message-ID: <20151019122126.GA15819@node.shutemov.name>
References: <1445256881-5205-1-git-send-email-vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1445256881-5205-1-git-send-email-vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Oct 19, 2015 at 03:14:41PM +0300, Vladimir Davydov wrote:
> If ALLOC_SPLIT_PTLOCKS is defined, ptlock_init may fail, in which case
> we shouldn't increment NR_PAGETABLE.
> 
> Since small allocations, such as ptlock, normally do not fail (currently
> they can fail if kmemcg is used though), this patch does not really fix
> anything and should be considered as a code cleanup.
> 
> Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
