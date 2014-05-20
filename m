Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id 804826B0036
	for <linux-mm@kvack.org>; Tue, 20 May 2014 03:28:57 -0400 (EDT)
Received: by mail-pb0-f53.google.com with SMTP id md12so62557pbc.40
        for <linux-mm@kvack.org>; Tue, 20 May 2014 00:28:57 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id xz4si23368860pac.71.2014.05.20.00.28.56
        for <linux-mm@kvack.org>;
        Tue, 20 May 2014 00:28:56 -0700 (PDT)
Date: Tue, 20 May 2014 00:28:34 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH V4 2/2] powerpc/pseries: init fault_around_order for
 pseries
Message-Id: <20140520002834.aefb5a90.akpm@linux-foundation.org>
In-Reply-To: <1399541296-18810-3-git-send-email-maddy@linux.vnet.ibm.com>
References: <1399541296-18810-1-git-send-email-maddy@linux.vnet.ibm.com>
	<1399541296-18810-3-git-send-email-maddy@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Madhavan Srinivasan <maddy@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@kernel.org, benh@kernel.crashing.org, paulus@samba.org, kirill.shutemov@linux.intel.com, rusty@rustcorp.com.au, riel@redhat.com, mgorman@suse.de, ak@linux.intel.com, peterz@infradead.org, mingo@kernel.org, dave.hansen@intel.com

On Thu,  8 May 2014 14:58:16 +0530 Madhavan Srinivasan <maddy@linux.vnet.ibm.com> wrote:

> --- a/arch/powerpc/platforms/pseries/pseries.h
> +++ b/arch/powerpc/platforms/pseries/pseries.h
> @@ -17,6 +17,8 @@ struct device_node;
>  extern void request_event_sources_irqs(struct device_node *np,
>  				       irq_handler_t handler, const char *name);
>  
> +extern unsigned int fault_around_order;

This isn't an appropriate header file for exporting something from core
mm - what happens if arch/mn10300 wants it?.

I guess include/linux/mm.h is the place.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
