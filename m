Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 1EB396B0005
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 06:32:26 -0400 (EDT)
Received: by mail-wm0-f47.google.com with SMTP id l6so139653536wml.1
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 03:32:26 -0700 (PDT)
Received: from mail-wm0-x230.google.com (mail-wm0-x230.google.com. [2a00:1450:400c:c09::230])
        by mx.google.com with ESMTPS id j5si28084240wjz.127.2016.04.11.03.32.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Apr 2016 03:32:25 -0700 (PDT)
Received: by mail-wm0-x230.google.com with SMTP id l6so139653004wml.1
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 03:32:24 -0700 (PDT)
Date: Mon, 11 Apr 2016 13:32:23 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 08/10] huge pagecache: extend mremap pmd rmap lockout to
 files
Message-ID: <20160411103223.GB22996@node.shutemov.name>
References: <alpine.LSU.2.11.1604051329480.5965@eggly.anvils>
 <alpine.LSU.2.11.1604051351280.5965@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1604051351280.5965@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andres Lagar-Cavilla <andreslc@google.com>, Yang Shi <yang.shi@linaro.org>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Apr 05, 2016 at 01:52:48PM -0700, Hugh Dickins wrote:
> Whatever huge pagecache implementation we go with, file rmap locking
> must be added to anon rmap locking, when mremap's move_page_tables()
> finds a pmd_trans_huge pmd entry: a simple change, let's do it now.
> 
> Factor out take_rmap_locks() and drop_rmap_locks() to handle the
> locking for make move_ptes() and move_page_tables(), and delete
> the VM_BUG_ON_VMA which rejected vm_file and required anon_vma.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>

Yeah, it's cleaner than my variant.

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
