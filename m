Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id EFF3D8309E
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 03:16:45 -0500 (EST)
Received: by mail-wm0-f45.google.com with SMTP id 128so144089086wmz.1
        for <linux-mm@kvack.org>; Mon, 08 Feb 2016 00:16:45 -0800 (PST)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id w124si15010225wmb.123.2016.02.08.00.16.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Feb 2016 00:16:44 -0800 (PST)
Received: by mail-wm0-x243.google.com with SMTP id 128so14330780wmz.3
        for <linux-mm@kvack.org>; Mon, 08 Feb 2016 00:16:44 -0800 (PST)
Date: Mon, 8 Feb 2016 10:16:42 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 1/2] mm: Make vm_get_page_prot arch specific.
Message-ID: <20160208081642.GC9075@node.shutemov.name>
References: <1454913660-27031-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1454913660-27031-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, mpe@ellerman.id.au, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Feb 08, 2016 at 12:10:59PM +0530, Aneesh Kumar K.V wrote:
> With next generation power processor, we are having a new mmu model
> [1] that require us to maintain a different linux page table format.
> 
> Inorder to support both current and future ppc64 systems with a single
> kernel we need to make sure kernel can select between different page
> table format at runtime. With the new MMU (radix MMU) added, we will
> have to dynamically switch between different protection map. Hence
> override vm_get_page_prot instead of using arch_vm_get_page_prot. We
> also drop arch_vm_get_page_prot since only powerpc used it.
> 
> [1] http://ibm.biz/power-isa3 (Needs registration).
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
