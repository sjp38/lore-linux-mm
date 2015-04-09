Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vn0-f50.google.com (mail-vn0-f50.google.com [209.85.216.50])
	by kanga.kvack.org (Postfix) with ESMTP id ABF1B6B0032
	for <linux-mm@kvack.org>; Thu,  9 Apr 2015 04:29:13 -0400 (EDT)
Received: by vnbf62 with SMTP id f62so20805343vnb.3
        for <linux-mm@kvack.org>; Thu, 09 Apr 2015 01:29:13 -0700 (PDT)
Received: from SMTP.CITRIX.COM (smtp.citrix.com. [66.165.176.89])
        by mx.google.com with ESMTPS id 9si3761132yhb.147.2015.04.09.01.29.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 09 Apr 2015 01:29:13 -0700 (PDT)
Message-ID: <55263856.9040607@citrix.com>
Date: Thu, 9 Apr 2015 09:29:10 +0100
From: David Vrabel <david.vrabel@citrix.com>
MIME-Version: 1.0
Subject: Re: [Xen-devel] [Patch V2 07/15] xen: check memory area against e820
 map
References: <1428562542-28488-1-git-send-email-jgross@suse.com>
 <1428562542-28488-8-git-send-email-jgross@suse.com>
In-Reply-To: <1428562542-28488-8-git-send-email-jgross@suse.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Juergen Gross <jgross@suse.com>, linux-kernel@vger.kernel.org, xen-devel@lists.xensource.com, konrad.wilk@oracle.com, david.vrabel@citrix.com, boris.ostrovsky@oracle.com, linux-mm@kvack.org

On 09/04/15 07:55, Juergen Gross wrote:
> Provide a service routine to check a physical memory area against the
> E820 map. The routine will return false if the complete area is RAM
> according to the E820 map and true otherwise.
> 
> Signed-off-by: Juergen Gross <jgross@suse.com>
> ---
>  arch/x86/xen/setup.c   | 23 +++++++++++++++++++++++
>  arch/x86/xen/xen-ops.h |  1 +
>  2 files changed, 24 insertions(+)
> 
> diff --git a/arch/x86/xen/setup.c b/arch/x86/xen/setup.c
> index 87251b4..4666adf 100644
> --- a/arch/x86/xen/setup.c
> +++ b/arch/x86/xen/setup.c
> @@ -573,6 +573,29 @@ static unsigned long __init xen_count_remap_pages(unsigned long max_pfn)
>  	return extra;
>  }
>  
> +bool __init xen_chk_e820_reserved(phys_addr_t start, phys_addr_t size)

Can you rename this to xen_is_e280_reserved().

Otherwise,

Reviewed-by: David Vrabel <david.vrabel@citrix.com>

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
