Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 0685E6B006E
	for <linux-mm@kvack.org>; Wed,  1 Jul 2015 14:45:33 -0400 (EDT)
Received: by wgqq4 with SMTP id q4so44283184wgq.1
        for <linux-mm@kvack.org>; Wed, 01 Jul 2015 11:45:32 -0700 (PDT)
Received: from johanna1.inet.fi (mta-out1.inet.fi. [62.71.2.229])
        by mx.google.com with ESMTP id xs10si4838343wjc.81.2015.07.01.11.45.30
        for <linux-mm@kvack.org>;
        Wed, 01 Jul 2015 11:45:31 -0700 (PDT)
Date: Wed, 1 Jul 2015 21:45:16 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mempolicy: get rid of duplicated check for
 vma(VM_PFNMAP) in queue_pages_range()
Message-ID: <20150701184516.GA20774@node.dhcp.inet.fi>
References: <20150701183058.GD32640@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150701183058.GD32640@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aristeu Rozanski <aris@redhat.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Dave Hansen <dave.hansen@intel.com>, Pavel Emelyanov <xemul@parallels.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-mm@kvack.org

On Wed, Jul 01, 2015 at 02:30:58PM -0400, Aristeu Rozanski wrote:
> This check was introduced as part of
> 	6f4576e3687 - mempolicy: apply page table walker on queue_pages_range()
> which got duplicated by
> 	48684a65b4e - mm: pagewalk: fix misbehavior of walk_page_range for vma(VM_PFNMAP)
> by reintroducing it earlier on queue_page_test_walk()
> 
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Cyrill Gorcunov <gorcunov@openvz.org>
> Cc: Dave Hansen <dave.hansen@intel.com>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Pavel Emelyanov <xemul@parallels.com>
> Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Signed-off-by: Aristeu Rozanski <aris@redhat.com>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
