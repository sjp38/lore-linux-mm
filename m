Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 8F71A6B0036
	for <linux-mm@kvack.org>; Mon, 30 Jun 2014 08:03:56 -0400 (EDT)
Received: by mail-wg0-f41.google.com with SMTP id a1so8021686wgh.12
        for <linux-mm@kvack.org>; Mon, 30 Jun 2014 05:03:56 -0700 (PDT)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.198])
        by mx.google.com with ESMTP id lv17si9957419wic.36.2014.06.30.05.03.55
        for <linux-mm@kvack.org>;
        Mon, 30 Jun 2014 05:03:55 -0700 (PDT)
Date: Mon, 30 Jun 2014 15:03:49 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v3 06/13] pagemap: use walk->vma instead of calling
 find_vma()
Message-ID: <20140630120349.GV19833@node.dhcp.inet.fi>
References: <1403295099-6407-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1403295099-6407-7-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1403295099-6407-7-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Fri, Jun 20, 2014 at 04:11:32PM -0400, Naoya Horiguchi wrote:
> Page table walker has the information of the current vma in mm_walk, so
> we don't have to call find_vma() in each pagemap_hugetlb_range() call.
> 
> NULL-vma check is omitted because we assume that we never run hugetlb_entry()
> callback on the address without vma. And even if it were broken, null pointer
> dereference would be detected, so we can get enough information for debugging.
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
