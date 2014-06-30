Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f169.google.com (mail-we0-f169.google.com [74.125.82.169])
	by kanga.kvack.org (Postfix) with ESMTP id 1490C6B0037
	for <linux-mm@kvack.org>; Mon, 30 Jun 2014 08:02:27 -0400 (EDT)
Received: by mail-we0-f169.google.com with SMTP id t60so8075586wes.14
        for <linux-mm@kvack.org>; Mon, 30 Jun 2014 05:02:27 -0700 (PDT)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.198])
        by mx.google.com with ESMTP id y16si23664521wju.93.2014.06.30.05.02.26
        for <linux-mm@kvack.org>;
        Mon, 30 Jun 2014 05:02:26 -0700 (PDT)
Date: Mon, 30 Jun 2014 15:02:18 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v3 05/13] clear_refs: remove clear_refs_private->vma and
 introduce clear_refs_test_walk()
Message-ID: <20140630120218.GU19833@node.dhcp.inet.fi>
References: <1403295099-6407-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1403295099-6407-6-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1403295099-6407-6-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Fri, Jun 20, 2014 at 04:11:31PM -0400, Naoya Horiguchi wrote:
> clear_refs_write() has some prechecks to determine if we really walk over
> a given vma. Now we have a test_walk() callback to filter vmas, so let's
> utilize it.
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
