Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 42B0F6B0036
	for <linux-mm@kvack.org>; Mon, 30 Jun 2014 07:58:34 -0400 (EDT)
Received: by mail-wi0-f179.google.com with SMTP id cc10so5853102wib.6
        for <linux-mm@kvack.org>; Mon, 30 Jun 2014 04:58:33 -0700 (PDT)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.199])
        by mx.google.com with ESMTP id cm4si9943488wib.21.2014.06.30.04.58.32
        for <linux-mm@kvack.org>;
        Mon, 30 Jun 2014 04:58:33 -0700 (PDT)
Date: Mon, 30 Jun 2014 14:58:26 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v3 04/13] smaps: remove mem_size_stats->vma and use
 walk_page_vma()
Message-ID: <20140630115826.GT19833@node.dhcp.inet.fi>
References: <1403295099-6407-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1403295099-6407-5-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1403295099-6407-5-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Fri, Jun 20, 2014 at 04:11:30PM -0400, Naoya Horiguchi wrote:
> pagewalk.c can handle vma in itself, so we don't have to pass vma via
> walk->private. And show_smap() walks pages on vma basis, so using
> walk_page_vma() is preferable.
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
