Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f182.google.com (mail-we0-f182.google.com [74.125.82.182])
	by kanga.kvack.org (Postfix) with ESMTP id D74B36B0031
	for <linux-mm@kvack.org>; Mon, 30 Jun 2014 08:20:26 -0400 (EDT)
Received: by mail-we0-f182.google.com with SMTP id q59so8116478wes.27
        for <linux-mm@kvack.org>; Mon, 30 Jun 2014 05:20:26 -0700 (PDT)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.198])
        by mx.google.com with ESMTP id hv4si23705901wjb.119.2014.06.30.05.20.25
        for <linux-mm@kvack.org>;
        Mon, 30 Jun 2014 05:20:25 -0700 (PDT)
Date: Mon, 30 Jun 2014 15:20:16 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v3 09/13] memcg: apply walk_page_vma()
Message-ID: <20140630122016.GY19833@node.dhcp.inet.fi>
References: <1403295099-6407-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1403295099-6407-10-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1403295099-6407-10-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Fri, Jun 20, 2014 at 04:11:35PM -0400, Naoya Horiguchi wrote:
> pagewalk.c can handle vma in itself, so we don't have to pass vma via
> walk->private. And both of mem_cgroup_count_precharge() and
> mem_cgroup_move_charge() walk over all vmas (not interested in outside vma,)
> so using walk_page_vma() is preferable.
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

My first thought was to suggest walk_page_range(0, -1, &walk) instead
since we walk over all vmas. But walk_page_range() uses find_vma() on each
iteration, which is expensive.
Is there a reason why we cannot use vma->vm_next in walk_page_range()?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
