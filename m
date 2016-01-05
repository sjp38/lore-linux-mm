Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 9EFA56B0003
	for <linux-mm@kvack.org>; Tue,  5 Jan 2016 14:04:47 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id yy13so126930934pab.3
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 11:04:47 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id b86si53022135pfj.138.2016.01.05.11.04.46
        for <linux-mm@kvack.org>;
        Tue, 05 Jan 2016 11:04:46 -0800 (PST)
Date: Tue, 5 Jan 2016 11:04:12 -0800
From: "Luck, Tony" <tony.luck@intel.com>
Subject: Re: [PATCH v3 05/17] ia64: Set System RAM type and descriptor
Message-ID: <20160105190412.GA6746@agluck-desk.sc.intel.com>
References: <1452020081-26534-1-git-send-email-toshi.kani@hpe.com>
 <1452020081-26534-5-git-send-email-toshi.kani@hpe.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1452020081-26534-5-git-send-email-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hpe.com>
Cc: akpm@linux-foundation.org, bp@alien8.de, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Tue, Jan 05, 2016 at 11:54:29AM -0700, Toshi Kani wrote:
> Change efi_initialize_iomem_resources() to set 'flags' and 'desc'
> from EFI memory types.  IORESOURCE_SYSRAM, a modifier bit, is
> set to 'flags' for System RAM as IORESOURCE_MEM is already set.
> IORESOURCE_SYSTEM_RAM is defined as (IORESOURCE_MEM|IORESOURCE_SYSRAM).
> I/O resource descritor is set to 'desc' for "ACPI Non-volatile
> Storage" and "Persistent Memory".
> 
> Also set IORESOURCE_SYSTEM_RAM to 'flags' for "Kernel code",
> "Kernel data", and "Kernel bss".
> 
Acked-by: Tony Luck <tony.luck@intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
