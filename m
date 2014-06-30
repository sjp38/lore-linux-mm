Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 581C86B0035
	for <linux-mm@kvack.org>; Mon, 30 Jun 2014 08:21:07 -0400 (EDT)
Received: by mail-wi0-f169.google.com with SMTP id hi2so5605724wib.4
        for <linux-mm@kvack.org>; Mon, 30 Jun 2014 05:21:06 -0700 (PDT)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.198])
        by mx.google.com with ESMTP id hv4si23705901wjb.119.2014.06.30.05.21.05
        for <linux-mm@kvack.org>;
        Mon, 30 Jun 2014 05:21:06 -0700 (PDT)
Date: Mon, 30 Jun 2014 15:21:00 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v3 10/13] arch/powerpc/mm/subpage-prot.c: use walk->vma
 and walk_page_vma()
Message-ID: <20140630122100.GZ19833@node.dhcp.inet.fi>
References: <1403295099-6407-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1403295099-6407-11-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1403295099-6407-11-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Fri, Jun 20, 2014 at 04:11:36PM -0400, Naoya Horiguchi wrote:
> We don't have to use mm_walk->private to pass vma to the callback function
> because of mm_walk->vma. And walk_page_vma() is useful if we walk over a
> single vma.
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
