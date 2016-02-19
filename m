Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f181.google.com (mail-pf0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 14920830B6
	for <linux-mm@kvack.org>; Thu, 18 Feb 2016 20:28:29 -0500 (EST)
Received: by mail-pf0-f181.google.com with SMTP id q63so41409210pfb.0
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 17:28:29 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id uf6si12802582pab.3.2016.02.18.17.28.28
        for <linux-mm@kvack.org>;
        Thu, 18 Feb 2016 17:28:28 -0800 (PST)
Subject: Re: [PATCH V3 01/30] mm: Make vm_get_page_prot arch specific.
References: <1455814254-10226-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1455814254-10226-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <56C66FBB.7000808@intel.com>
Date: Thu, 18 Feb 2016 17:28:27 -0800
MIME-Version: 1.0
In-Reply-To: <1455814254-10226-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

On 02/18/2016 08:50 AM, Aneesh Kumar K.V wrote:
> With next generation power processor, we are having a new mmu model
> [1] that require us to maintain a different linux page table format.
> 
> Inorder to support both current and future ppc64 systems with a single
> kernel we need to make sure kernel can select between different page
> table format at runtime. With the new MMU (radix MMU) added, we will
> have to dynamically switch between different protection map. Hence
> override vm_get_page_prot instead of using arch_vm_get_page_prot. We
> also drop arch_vm_get_page_prot since only powerpc used it.

Hi Aneesh,

I've got some patches I'm hoping to get in to 4.6 that start using
arch_vm_get_page_prot() on x86:

> http://git.kernel.org/cgit/linux/kernel/git/daveh/x86-pkeys.git/commit/?h=pkeys-v024&id=aa1e61398fb598869981cfe48275cff832945669

So I'd prefer that it stay in place. :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
