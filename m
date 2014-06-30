Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id D722A6B0035
	for <linux-mm@kvack.org>; Mon, 30 Jun 2014 07:56:13 -0400 (EDT)
Received: by mail-wg0-f48.google.com with SMTP id n12so7928329wgh.7
        for <linux-mm@kvack.org>; Mon, 30 Jun 2014 04:56:13 -0700 (PDT)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.198])
        by mx.google.com with ESMTP id e17si1264263wjx.19.2014.06.30.04.56.12
        for <linux-mm@kvack.org>;
        Mon, 30 Jun 2014 04:56:12 -0700 (PDT)
Date: Mon, 30 Jun 2014 14:56:05 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v3 03/13] pagewalk: add walk_page_vma()
Message-ID: <20140630115605.GS19833@node.dhcp.inet.fi>
References: <1403295099-6407-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1403295099-6407-4-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1403295099-6407-4-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Fri, Jun 20, 2014 at 04:11:29PM -0400, Naoya Horiguchi wrote:
> Introduces walk_page_vma(), which is useful for the callers which want to
> walk over a given vma.  It's used by later patches.
> 
> ChangeLog:
> - check walk_page_test's return value instead of walk->skip
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
