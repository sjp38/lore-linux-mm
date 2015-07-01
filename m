Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f176.google.com (mail-lb0-f176.google.com [209.85.217.176])
	by kanga.kvack.org (Postfix) with ESMTP id C91E36B0253
	for <linux-mm@kvack.org>; Wed,  1 Jul 2015 16:15:57 -0400 (EDT)
Received: by lbbpo10 with SMTP id po10so19707142lbb.3
        for <linux-mm@kvack.org>; Wed, 01 Jul 2015 13:15:57 -0700 (PDT)
Received: from mail-lb0-x22c.google.com (mail-lb0-x22c.google.com. [2a00:1450:4010:c04::22c])
        by mx.google.com with ESMTPS id kd4si2643242lbc.42.2015.07.01.13.15.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Jul 2015 13:15:56 -0700 (PDT)
Received: by lbcui10 with SMTP id ui10so19712736lbc.0
        for <linux-mm@kvack.org>; Wed, 01 Jul 2015 13:15:55 -0700 (PDT)
Date: Wed, 1 Jul 2015 23:15:52 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH] mempolicy: get rid of duplicated check for
 vma(VM_PFNMAP) in queue_pages_range()
Message-ID: <20150701201552.GB11274@uranus>
References: <20150701183058.GD32640@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150701183058.GD32640@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aristeu Rozanski <aris@redhat.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Pavel Emelyanov <xemul@parallels.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-mm@kvack.org

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
Acked-by: Cyrill Gorcunov <gorcunov@openvz.org>

Thank you!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
