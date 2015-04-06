Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id CC02E6B0038
	for <linux-mm@kvack.org>; Mon,  6 Apr 2015 08:03:35 -0400 (EDT)
Received: by wizk4 with SMTP id k4so28620032wiz.1
        for <linux-mm@kvack.org>; Mon, 06 Apr 2015 05:03:35 -0700 (PDT)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.227])
        by mx.google.com with ESMTP id na9si7460965wic.65.2015.04.06.05.03.33
        for <linux-mm@kvack.org>;
        Mon, 06 Apr 2015 05:03:34 -0700 (PDT)
Date: Mon, 6 Apr 2015 15:03:22 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 1/2 mmotm] mm/migrate: check-before-clear PageSwapCache
Message-ID: <20150406120322.GA8375@node.dhcp.inet.fi>
References: <20150406062017.GB11515@hori1.linux.bs1.fc.nec.co.jp>
 <20150406072551.GA7539@node.dhcp.inet.fi>
 <20150406074636.GB22950@hori1.linux.bs1.fc.nec.co.jp>
 <20150406081318.GA7373@hori1.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150406081318.GA7373@hori1.linux.bs1.fc.nec.co.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

On Mon, Apr 06, 2015 at 08:13:19AM +0000, Naoya Horiguchi wrote:
> With page flag sanitization patchset, an invalid usage of ClearPageSwapCache()
> is detected in migration_page_copy().
> migrate_page_copy() is shared by both normal and hugepage (both thp and hugetlb)
> code path, so let's check PageSwapCache() and clear it if it's set to avoid
> misuse of the invalid clear operation.
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
