Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id C66E99003C7
	for <linux-mm@kvack.org>; Wed, 22 Jul 2015 07:31:58 -0400 (EDT)
Received: by wicmv11 with SMTP id mv11so77325365wic.0
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 04:31:58 -0700 (PDT)
Received: from mail-wi0-x22d.google.com (mail-wi0-x22d.google.com. [2a00:1450:400c:c05::22d])
        by mx.google.com with ESMTPS id jf20si24259516wic.44.2015.07.22.04.31.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Jul 2015 04:31:57 -0700 (PDT)
Received: by wicgb10 with SMTP id gb10so93830583wic.1
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 04:31:56 -0700 (PDT)
Subject: Re: [PATCH] mm: rename and document alloc_pages_exact_node
References: <1437486951-19898-1-git-send-email-vbabka@suse.cz>
From: Paolo Bonzini <pbonzini@redhat.com>
Message-ID: <55AF7F28.2020504@redhat.com>
Date: Wed, 22 Jul 2015 13:31:52 +0200
MIME-Version: 1.0
In-Reply-To: <1437486951-19898-1-git-send-email-vbabka@suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, cbe-oss-dev@lists.ozlabs.org, kvm@vger.kernel.org, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Greg Thelen <gthelen@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Arnd Bergmann <arnd@arndb.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Gleb Natapov <gleb@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>



On 21/07/2015 15:55, Vlastimil Babka wrote:
> diff --git a/arch/x86/kvm/vmx.c b/arch/x86/kvm/vmx.c
> index 2d73807..a8723a8 100644
> --- a/arch/x86/kvm/vmx.c
> +++ b/arch/x86/kvm/vmx.c
> @@ -3158,7 +3158,7 @@ static struct vmcs *alloc_vmcs_cpu(int cpu)
>  	struct page *pages;
>  	struct vmcs *vmcs;
>  
> -	pages = alloc_pages_exact_node(node, GFP_KERNEL, vmcs_config.order);
> +	pages = alloc_pages_prefer_node(node, GFP_KERNEL, vmcs_config.order);
>  	if (!pages)
>  		return NULL;
>  	vmcs = page_address(pages);

Even though there's a pretty strong preference for the "right" node,
things can work if the node is the wrong one.  The order is always zero
in practice, so the allocation should succeed.

Paolo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
