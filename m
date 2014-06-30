Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 8FA986B0031
	for <linux-mm@kvack.org>; Mon, 30 Jun 2014 06:23:21 -0400 (EDT)
Received: by mail-wg0-f49.google.com with SMTP id y10so8063885wgg.32
        for <linux-mm@kvack.org>; Mon, 30 Jun 2014 03:23:20 -0700 (PDT)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.199])
        by mx.google.com with ESMTP id dd4si2319108wjb.26.2014.06.30.03.23.19
        for <linux-mm@kvack.org>;
        Mon, 30 Jun 2014 03:23:20 -0700 (PDT)
Date: Mon, 30 Jun 2014 13:23:06 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v3 01/13] mm/pagewalk: remove pgd_entry() and pud_entry()
Message-ID: <20140630102306.GA19833@node.dhcp.inet.fi>
References: <1403295099-6407-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1403295099-6407-2-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1403295099-6407-2-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Fri, Jun 20, 2014 at 04:11:27PM -0400, Naoya Horiguchi wrote:
> Currently no user of page table walker sets ->pgd_entry() or ->pud_entry(),
> so checking their existence in each loop is just wasting CPU cycle.
> So let's remove it to reduce overhead.
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
