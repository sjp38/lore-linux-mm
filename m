Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f54.google.com (mail-la0-f54.google.com [209.85.215.54])
	by kanga.kvack.org (Postfix) with ESMTP id 68F526B0035
	for <linux-mm@kvack.org>; Mon, 14 Jul 2014 02:40:23 -0400 (EDT)
Received: by mail-la0-f54.google.com with SMTP id mc6so2568634lab.13
        for <linux-mm@kvack.org>; Sun, 13 Jul 2014 23:40:22 -0700 (PDT)
Received: from mail-lb0-x232.google.com (mail-lb0-x232.google.com [2a00:1450:4010:c04::232])
        by mx.google.com with ESMTPS id du4si10402594lac.17.2014.07.13.23.40.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 13 Jul 2014 23:40:21 -0700 (PDT)
Received: by mail-lb0-f178.google.com with SMTP id 10so2528714lbg.9
        for <linux-mm@kvack.org>; Sun, 13 Jul 2014 23:40:20 -0700 (PDT)
Date: Mon, 14 Jul 2014 10:40:19 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH -mm v5 12/13] mm: /proc/pid/clear_refs: avoid
 split_huge_page()
Message-ID: <20140714064019.GF19702@moon>
References: <1405103749-23506-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1405103749-23506-13-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1405103749-23506-13-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Pavel Emelyanov <xemul@parallels.com>, Andrea Arcangeli <aarcange@redhat.com>

On Fri, Jul 11, 2014 at 02:35:48PM -0400, Naoya Horiguchi wrote:
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> 
> Currently pagewalker splits all THP pages on any clear_refs request.  It's
> not necessary.  We can handle this on PMD level.
> 
> One side effect is that soft dirty will potentially see more dirty memory,
> since we will mark whole THP page dirty at once.
> 
> Sanity checked with CRIU test suite. More testing is required.
> 
> ChangeLog:
> - move code for thp to clear_refs_pte_range()
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Pavel Emelyanov <xemul@parallels.com>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Dave Hansen <dave.hansen@intel.com>
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Cyrill Gorcunov <gorcunov@gmail.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Reviewed-by: Cyrill Gorcunov <gorcunov@openvz.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
