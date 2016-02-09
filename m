Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id F288B6B0005
	for <linux-mm@kvack.org>; Tue,  9 Feb 2016 14:42:09 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id 128so210400778wmz.1
        for <linux-mm@kvack.org>; Tue, 09 Feb 2016 11:42:09 -0800 (PST)
Received: from mail-wm0-x234.google.com (mail-wm0-x234.google.com. [2a00:1450:400c:c09::234])
        by mx.google.com with ESMTPS id e8si51044494wjx.113.2016.02.09.11.42.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Feb 2016 11:42:08 -0800 (PST)
Received: by mail-wm0-x234.google.com with SMTP id g62so37817790wme.0
        for <linux-mm@kvack.org>; Tue, 09 Feb 2016 11:42:08 -0800 (PST)
Date: Tue, 9 Feb 2016 21:42:06 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH V2] mm: Some arch may want to use HPAGE_PMD related
 values as variables
Message-ID: <20160209194206.GA22327@node.shutemov.name>
References: <1455034304-15301-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1455034304-15301-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, mpe@ellerman.id.au, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Feb 09, 2016 at 09:41:44PM +0530, Aneesh Kumar K.V wrote:
> With next generation power processor, we are having a new mmu model
> [1] that require us to maintain a different linux page table format.
> 
> Inorder to support both current and future ppc64 systems with a single
> kernel we need to make sure kernel can select between different page
> table format at runtime. With the new MMU (radix MMU) added, we will
> have two different pmd hugepage size 16MB for hash model and 2MB for
> Radix model. Hence make HPAGE_PMD related values as a variable.
> 
> [1] http://ibm.biz/power-isa3 (Needs registration).
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

I guess it should have my signed-off-by ;)

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
