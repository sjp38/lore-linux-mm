Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id E62CC2802C4
	for <linux-mm@kvack.org>; Wed, 15 Jul 2015 19:50:39 -0400 (EDT)
Received: by pacan13 with SMTP id an13so32214288pac.1
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 16:50:39 -0700 (PDT)
Received: from mail-pd0-x22c.google.com (mail-pd0-x22c.google.com. [2607:f8b0:400e:c02::22c])
        by mx.google.com with ESMTPS id iu9si9881717pbc.77.2015.07.15.16.50.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jul 2015 16:50:39 -0700 (PDT)
Received: by pdjr16 with SMTP id r16so33284268pdj.3
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 16:50:39 -0700 (PDT)
Date: Thu, 16 Jul 2015 08:50:45 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 4/5] mm, madvise: use vma_is_anonymous() to check for
 anon VMA
Message-ID: <20150715235044.GC988@bgram>
References: <1436784852-144369-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1436784852-144369-5-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1436784852-144369-5-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jul 13, 2015 at 01:54:11PM +0300, Kirill A. Shutemov wrote:
> !vma->vm_file is not reliable to detect anon VMA, because not all
> drivers bother set it. Let's use vma_is_anonymous() instead.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Minchan Kim <minchan@kernel.org>
Acked-by: Minchan Kim <minchan@kernel.org>

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
