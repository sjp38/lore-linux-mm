Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id B6CE88E0002
	for <linux-mm@kvack.org>; Mon, 14 Jan 2019 18:08:00 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id u17so444171pgn.17
        for <linux-mm@kvack.org>; Mon, 14 Jan 2019 15:08:00 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id t65si1576619pfd.246.2019.01.14.15.07.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Jan 2019 15:07:59 -0800 (PST)
Subject: Re: [PATCHv2 1/7] x86/mm: concentrate the code to memblock allocator
 enabled
References: <1547183577-20309-1-git-send-email-kernelfans@gmail.com>
 <1547183577-20309-2-git-send-email-kernelfans@gmail.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <96233c0c-940d-8d7c-b3be-d8863c026996@intel.com>
Date: Mon, 14 Jan 2019 15:07:59 -0800
MIME-Version: 1.0
In-Reply-To: <1547183577-20309-2-git-send-email-kernelfans@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pingfan Liu <kernelfans@gmail.com>, linux-kernel@vger.kernel.org
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Yinghai Lu <yinghai@kernel.org>, Tejun Heo <tj@kernel.org>, Chao Fan <fanc.fnst@cn.fujitsu.com>, Baoquan He <bhe@redhat.com>, Juergen Gross <jgross@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, x86@kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org

On 1/10/19 9:12 PM, Pingfan Liu wrote:
> This patch identifies the point where memblock alloc start. It has no
> functional.

It has no functional ... what?  Effects?

> -	memblock_set_current_limit(ISA_END_ADDRESS);
> -	e820__memblock_setup();
> -
>  	reserve_bios_regions();
>  
>  	if (efi_enabled(EFI_MEMMAP)) {
> @@ -1113,6 +1087,8 @@ void __init setup_arch(char **cmdline_p)
>  		efi_reserve_boot_services();
>  	}
>  
> +	memblock_set_current_limit(0, ISA_END_ADDRESS, false);
> +	e820__memblock_setup();

It looks like you changed the arguments passed to
memblock_set_current_limit().  How can this even compile?  Did you mean
that this patch is not functional?
