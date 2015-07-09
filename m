Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id 71BEF6B0038
	for <linux-mm@kvack.org>; Wed,  8 Jul 2015 20:58:14 -0400 (EDT)
Received: by igrv9 with SMTP id v9so181399177igr.1
        for <linux-mm@kvack.org>; Wed, 08 Jul 2015 17:58:14 -0700 (PDT)
Received: from mail-ie0-x231.google.com (mail-ie0-x231.google.com. [2607:f8b0:4001:c03::231])
        by mx.google.com with ESMTPS id co1si4132207igb.16.2015.07.08.17.58.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Jul 2015 17:58:13 -0700 (PDT)
Received: by iecuq6 with SMTP id uq6so167084427iec.2
        for <linux-mm@kvack.org>; Wed, 08 Jul 2015 17:58:13 -0700 (PDT)
Date: Wed, 8 Jul 2015 17:58:12 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mempolicy: get rid of duplicated check for vma(VM_PFNMAP)
 in queue_pages_range()
In-Reply-To: <20150701183058.GD32640@redhat.com>
Message-ID: <alpine.DEB.2.10.1507081758000.16585@chino.kir.corp.google.com>
References: <20150701183058.GD32640@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aristeu Rozanski <aris@redhat.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Dave Hansen <dave.hansen@intel.com>, Pavel Emelyanov <xemul@parallels.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-mm@kvack.org

On Wed, 1 Jul 2015, Aristeu Rozanski wrote:

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

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
