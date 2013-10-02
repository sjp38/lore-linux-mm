Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id BC5A46B0036
	for <linux-mm@kvack.org>; Wed,  2 Oct 2013 13:48:29 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rp2so1221051pbb.28
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 10:48:29 -0700 (PDT)
Message-ID: <524C5BFB.5050501@zytor.com>
Date: Wed, 02 Oct 2013 10:46:35 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [RESEND PATCH] x86: add phys addr validity check for /dev/mem
 mmap
References: <20131002160514.GA25471@localhost.localdomain>
In-Reply-To: <20131002160514.GA25471@localhost.localdomain>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Frantisek Hrbata <fhrbata@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, tglx@linutronix.de, mingo@redhat.com, x86@kernel.org, oleg@redhat.com, kamaleshb@in.ibm.com, hechjie@cn.ibm.com, akpm@linux-foundation.org, dave.hansen@intel.com

On 10/02/2013 09:05 AM, Frantisek Hrbata wrote:
> +
> +int valid_phys_addr_range(phys_addr_t addr, size_t count)
> +{
> +	return addr + count <= __pa(high_memory);
> +}
> +
> +int valid_mmap_phys_addr_range(unsigned long pfn, size_t count)
> +{
> +	resource_size_t addr = (pfn << PAGE_SHIFT) + count;
> +	return phys_addr_valid(addr);
> +}
> 

The latter has overflow problems.

The former I realize matches the current /dev/mem, but it is still just
plain wrong in multiple ways.

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
