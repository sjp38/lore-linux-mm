Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2CA466B02E3
	for <linux-mm@kvack.org>; Fri, 11 Nov 2016 05:06:17 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id a20so23441554wme.5
        for <linux-mm@kvack.org>; Fri, 11 Nov 2016 02:06:17 -0800 (PST)
Received: from mail-wm0-x22f.google.com (mail-wm0-x22f.google.com. [2a00:1450:400c:c09::22f])
        by mx.google.com with ESMTPS id r137si10172865wmb.26.2016.11.11.02.06.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Nov 2016 02:06:15 -0800 (PST)
Received: by mail-wm0-x22f.google.com with SMTP id t79so82560186wmt.0
        for <linux-mm@kvack.org>; Fri, 11 Nov 2016 02:06:15 -0800 (PST)
Date: Fri, 11 Nov 2016 13:06:10 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH V2] mm: move vma_is_anonymous check within
 pmd_move_must_withdraw
Message-ID: <20161111100610.GA19382@node.shutemov.name>
References: <201611071732.njM40txT%fengguang.wu@intel.com>
 <20161107144639.24048-1-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161107144639.24048-1-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On Mon, Nov 07, 2016 at 08:16:39PM +0530, Aneesh Kumar K.V wrote:
> Architectures like ppc64 want to use page table deposit/withraw
> even with huge pmd dax entries. Allow arch to override the
> vma_is_anonymous check by moving that to pmd_move_must_withdraw
> function
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
