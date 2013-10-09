Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 4418F6B0039
	for <linux-mm@kvack.org>; Wed,  9 Oct 2013 13:18:48 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id z10so1246993pdj.17
        for <linux-mm@kvack.org>; Wed, 09 Oct 2013 10:18:47 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <20131009164951.GA29751@localhost>
References: <20131009164951.GA29751@localhost>
Subject: RE: [page->ptl] BUG: unable to handle kernel NULL pointer dereference
 at 00000010
Content-Transfer-Encoding: 7bit
Message-Id: <20131009171828.693D0E0090@blue.fi.intel.com>
Date: Wed,  9 Oct 2013 20:18:28 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Fengguang Wu wrote:
> Greetings,
> 
> I got the below dmesg and the first bad commit is
> 
> commit c7727a852968b09a9a5756dc7c85c30287c6ada3
> Author: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Date:   Wed Oct 9 16:45:45 2013 +0300
> 
>     mm: dynamic allocate page->ptl if it cannot be embedded to struct page
>     
>     Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Thanks, I'll fix it tomorrow.

Just to clarify: the commit is from my devel branch. It doesn't affect any
upstream tree.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
