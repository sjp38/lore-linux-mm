Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f173.google.com (mail-we0-f173.google.com [74.125.82.173])
	by kanga.kvack.org (Postfix) with ESMTP id 3EB356B0038
	for <linux-mm@kvack.org>; Mon,  2 Feb 2015 06:26:36 -0500 (EST)
Received: by mail-we0-f173.google.com with SMTP id w62so38426631wes.4
        for <linux-mm@kvack.org>; Mon, 02 Feb 2015 03:26:35 -0800 (PST)
Received: from cpsmtpb-ews08.kpnxchange.com (cpsmtpb-ews08.kpnxchange.com. [213.75.39.13])
        by mx.google.com with ESMTP id fk5si5759916wib.15.2015.02.02.03.26.34
        for <linux-mm@kvack.org>;
        Mon, 02 Feb 2015 03:26:34 -0800 (PST)
Message-ID: <1422876393.19005.21.camel@x220>
Subject: Re: [PATCHv2 17/19] x86: expose number of page table levels on
 Kconfig level
From: Paul Bolle <pebolle@tiscali.nl>
Date: Mon, 02 Feb 2015 12:26:33 +0100
In-Reply-To: <1422664208-220779-1-git-send-email-kirill.shutemov@linux.intel.com>
References: 
	<1422629008-13689-18-git-send-email-kirill.shutemov@linux.intel.com>
	 <1422664208-220779-1-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter
 Anvin" <hpa@zytor.com>

On Sat, 2015-01-31 at 02:30 +0200, Kirill A. Shutemov wrote:
> We would want to use number of page table level to define mm_struct.
> Let's expose it as CONFIG_PGTABLE_LEVELS.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: "H. Peter Anvin" <hpa@zytor.com>
> ---
>  v2: s/PAGETABLE_LEVELS/CONFIG_PGTABLE_LEVELS/ include/trace/events/xen.h

Isn't there some (informal) rule to update an entire series to a next
version (and not only the patches that were changed in that version)?
Anyhow, it seems you sent a v2 for 05/19, 11/19 and 17/19 only. Is that
correct?

Thanks,


Paul Bolle

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
