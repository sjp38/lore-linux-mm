Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 850B06B0005
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 06:28:30 -0400 (EDT)
Received: by mail-wm0-f45.google.com with SMTP id a140so6665867wma.0
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 03:28:30 -0700 (PDT)
Received: from mail-wm0-x22b.google.com (mail-wm0-x22b.google.com. [2a00:1450:400c:c09::22b])
        by mx.google.com with ESMTPS id 191si17642581wmk.101.2016.04.11.03.28.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Apr 2016 03:28:29 -0700 (PDT)
Received: by mail-wm0-x22b.google.com with SMTP id a140so6665265wma.0
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 03:28:28 -0700 (PDT)
Date: Mon, 11 Apr 2016 13:28:26 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 07/10] huge mm: move_huge_pmd does not need new_vma
Message-ID: <20160411102826.GA22996@node.shutemov.name>
References: <alpine.LSU.2.11.1604051329480.5965@eggly.anvils>
 <alpine.LSU.2.11.1604051349410.5965@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1604051349410.5965@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andres Lagar-Cavilla <andreslc@google.com>, Yang Shi <yang.shi@linaro.org>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Apr 05, 2016 at 01:51:15PM -0700, Hugh Dickins wrote:
> Remove move_huge_pmd()'s redundant new_vma arg: all it was used for was
> a VM_NOHUGEPAGE check on new_vma flags, but the new_vma is cloned from
> the old vma, so a trans_huge_pmd in the new_vma will be as acceptable
> as it was in the old vma, alignment and size permitting.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
