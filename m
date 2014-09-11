Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id AE9BA6B0035
	for <linux-mm@kvack.org>; Thu, 11 Sep 2014 01:41:06 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id lj1so10012602pab.13
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 22:41:06 -0700 (PDT)
Received: from mail-pa0-x249.google.com (mail-pa0-x249.google.com [2607:f8b0:400e:c03::249])
        by mx.google.com with ESMTPS id ta5si30648060pac.90.2014.09.10.22.41.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 10 Sep 2014 22:41:05 -0700 (PDT)
Received: by mail-pa0-f73.google.com with SMTP id kx10so1276592pab.2
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 22:41:05 -0700 (PDT)
Date: Wed, 10 Sep 2014 22:41:04 -0700
From: Peter Feiner <pfeiner@google.com>
Subject: Re: [PATCH] mm: softdirty: unmapped addresses between VMAs are clean
Message-ID: <20140911054104.GA31069@google.com>
References: <1410391486-9106-1-git-send-email-pfeiner@google.com>
 <20140910163628.66302ac77f7835ba5df2f49c@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140910163628.66302ac77f7835ba5df2f49c@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>, Cyrill Gorcunov <gorcunov@openvz.org>, Pavel Emelyanov <xemul@parallels.com>, Jamie Liu <jamieliu@google.com>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

On Wed, Sep 10, 2014 at 04:36:28PM -0700, Andrew Morton wrote:
> On Wed, 10 Sep 2014 16:24:46 -0700 Peter Feiner <pfeiner@google.com> wrote:
> > @@ -1048,32 +1048,51 @@ static int pagemap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
> > +	while (1) {
> > +		unsigned long vm_start = end;
> 
> Did you really mean to do that?  If so, perhaps a little comment to
> explain how it works?

It's the same idea that I used in the pagemap_pte_hole patch that I submitted
today: if vma is NULL, then we fill in the pagemap from (addr) to (end) with
non-present pagemap entries. 

Should I submit a v2 with a comment?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
