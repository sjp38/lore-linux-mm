Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f42.google.com (mail-la0-f42.google.com [209.85.215.42])
	by kanga.kvack.org (Postfix) with ESMTP id 0909D6B0035
	for <linux-mm@kvack.org>; Sun, 24 Aug 2014 15:22:54 -0400 (EDT)
Received: by mail-la0-f42.google.com with SMTP id pv20so11992317lab.29
        for <linux-mm@kvack.org>; Sun, 24 Aug 2014 12:22:53 -0700 (PDT)
Received: from mail-la0-x22c.google.com (mail-la0-x22c.google.com [2a00:1450:4010:c03::22c])
        by mx.google.com with ESMTPS id t15si49771642lbk.31.2014.08.24.12.22.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 24 Aug 2014 12:22:52 -0700 (PDT)
Received: by mail-la0-f44.google.com with SMTP id el20so11918859lab.17
        for <linux-mm@kvack.org>; Sun, 24 Aug 2014 12:22:52 -0700 (PDT)
Date: Sun, 24 Aug 2014 23:22:51 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH v3] mm: softdirty: enable write notifications on VMAs
 after VM_SOFTDIRTY cleared
Message-ID: <20140824192251.GL25918@moon>
References: <1408571182-28750-1-git-send-email-pfeiner@google.com>
 <1408844584-30380-1-git-send-email-pfeiner@google.com>
 <20140824075924.GA27392@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140824075924.GA27392@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Peter Feiner <pfeiner@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Pavel Emelyanov <xemul@parallels.com>, Jamie Liu <jamieliu@google.com>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>

On Sun, Aug 24, 2014 at 10:59:24AM +0300, Kirill A. Shutemov wrote:
...
> > diff --git a/mm/mmap.c b/mm/mmap.c
> > index c1f2ea4..1b61fbc 100644
> > --- a/mm/mmap.c
> > +++ b/mm/mmap.c
> > @@ -1470,6 +1470,10 @@ int vma_wants_writenotify(struct vm_area_struct *vma)
> >  	if (vma->vm_ops && vma->vm_ops->page_mkwrite)
> >  		return 1;
> >  
> > +	/* Do we need to track softdirty? */
> > +	if (!(vm_flags & VM_SOFTDIRTY))
> 
> This will give false-positive if CONFIG_MEM_SOFT_DIRTY is disabled, since
> VM_SOFTDIRTY is 0 in this case:
> 
> 	if (IS_ENABLED(CONFIG_MEM_SOFT_DIRTY) && !(vm_flags & VM_SOFTDIRTY))
> 
> Otherwise looks good to me.
> 
> Suggested-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Reviewed-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Really sorry for delay. Thanks a huge, guys!

Reviewed-by: Cyrill Gorcunov <gorcunov@openvz.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
