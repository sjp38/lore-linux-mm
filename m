Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0541C8E0001
	for <linux-mm@kvack.org>; Sun, 16 Dec 2018 05:44:17 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id t26so7659039pgu.18
        for <linux-mm@kvack.org>; Sun, 16 Dec 2018 02:44:16 -0800 (PST)
Received: from smtp.nue.novell.com (smtp.nue.novell.com. [195.135.221.5])
        by mx.google.com with ESMTPS id z143si9236356pfc.97.2018.12.16.02.44.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 16 Dec 2018 02:44:15 -0800 (PST)
Subject: Re: [PATCH v1 6/9] arm64: kexec: no need to ClearPageReserved()
References: <20181214111014.15672-1-david@redhat.com>
 <20181214111014.15672-7-david@redhat.com>
From: Matthias Brugger <mbrugger@suse.com>
Message-ID: <318b0fe0-1a38-335d-26c1-ad7bac9d811d@suse.com>
Date: Sun, 16 Dec 2018 11:44:00 +0100
MIME-Version: 1.0
In-Reply-To: <20181214111014.15672-7-david@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>, linux-mm@kvack.org
Cc: Mark Rutland <mark.rutland@arm.com>, linux-s390@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Bhupesh Sharma <bhsharma@redhat.com>, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, linux-m68k@lists.linux-m68k.org, Dave Kleikamp <dave.kleikamp@oracle.com>, linux-mediatek@lists.infradead.org, James Morse <james.morse@arm.com>, linux-riscv@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, Andrew Morton <akpm@linux-foundation.org>, linux-arm-kernel@lists.infradead.org



On 14/12/2018 12:10, David Hildenbrand wrote:
> This will be done by free_reserved_page().
> 
> Cc: Catalin Marinas <catalin.marinas@arm.com>
> Cc: Will Deacon <will.deacon@arm.com>
> Cc: Bhupesh Sharma <bhsharma@redhat.com>
> Cc: James Morse <james.morse@arm.com>
> Cc: Marc Zyngier <marc.zyngier@arm.com>
> Cc: Dave Kleikamp <dave.kleikamp@oracle.com>
> Cc: Mark Rutland <mark.rutland@arm.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Matthew Wilcox <willy@infradead.org>
> Acked-by: James Morse <james.morse@arm.com>
> Signed-off-by: David Hildenbrand <david@redhat.com>

Reviewed-by: Matthias Brugger <mbrugger@suse.com>

> ---
>  arch/arm64/kernel/machine_kexec.c | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/arch/arm64/kernel/machine_kexec.c b/arch/arm64/kernel/machine_kexec.c
> index aa9c94113700..6f0587b5e941 100644
> --- a/arch/arm64/kernel/machine_kexec.c
> +++ b/arch/arm64/kernel/machine_kexec.c
> @@ -361,7 +361,6 @@ void crash_free_reserved_phys_range(unsigned long begin, unsigned long end)
>  
>  	for (addr = begin; addr < end; addr += PAGE_SIZE) {
>  		page = phys_to_page(addr);
> -		ClearPageReserved(page);
>  		free_reserved_page(page);
>  	}
>  }
> 
