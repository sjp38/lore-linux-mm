Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f182.google.com (mail-io0-f182.google.com [209.85.223.182])
	by kanga.kvack.org (Postfix) with ESMTP id C1306830B6
	for <linux-mm@kvack.org>; Thu, 18 Feb 2016 18:52:43 -0500 (EST)
Received: by mail-io0-f182.google.com with SMTP id z135so92451781iof.0
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 15:52:43 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id a7si8619236igo.96.2016.02.18.15.52.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Feb 2016 15:52:43 -0800 (PST)
Date: Fri, 19 Feb 2016 10:15:46 +1100
From: Paul Mackerras <paulus@ozlabs.org>
Subject: Re: [PATCH V3 01/30] mm: Make vm_get_page_prot arch specific.
Message-ID: <20160218231546.GC2765@fergus.ozlabs.ibm.com>
References: <1455814254-10226-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1455814254-10226-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1455814254-10226-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

On Thu, Feb 18, 2016 at 10:20:25PM +0530, Aneesh Kumar K.V wrote:
> With next generation power processor, we are having a new mmu model
> [1] that require us to maintain a different linux page table format.
> 
> Inorder to support both current and future ppc64 systems with a single
> kernel we need to make sure kernel can select between different page
> table format at runtime. With the new MMU (radix MMU) added, we will
> have to dynamically switch between different protection map. Hence
> override vm_get_page_prot instead of using arch_vm_get_page_prot. We
> also drop arch_vm_get_page_prot since only powerpc used it.

This seems like unnecessary churn to me.  Let's just make hash use the
same values as radix for things like _PAGE_RW, _PAGE_EXEC etc., and
then we don't need any of this.

Paul.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
