Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 26331440846
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 09:07:59 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id s9so789304wrs.9
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 06:07:59 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id 59si3344909wrh.278.2017.08.24.06.07.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 24 Aug 2017 06:07:57 -0700 (PDT)
Date: Thu, 24 Aug 2017 15:07:42 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 1/2] nfit: Use init_completion() in
 acpi_nfit_flush_probe()
In-Reply-To: <20170823152542.5150-2-boqun.feng@gmail.com>
Message-ID: <alpine.DEB.2.20.1708241507160.1860@nanos>
References: <20170823152542.5150-1-boqun.feng@gmail.com> <20170823152542.5150-2-boqun.feng@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boqun Feng <boqun.feng@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, walken@google.com, Byungchul Park <byungchul.park@lge.com>, Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, willy@infradead.org, Nicholas Piggin <npiggin@gmail.com>, kernel-team@lge.com, Dan Williams <dan.j.williams@intel.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, linux-nvdimm@lists.01.org, linux-acpi@vger.kernel.org

On Wed, 23 Aug 2017, Boqun Feng wrote:

> There is no need to use COMPLETION_INITIALIZER_ONSTACK() in
> acpi_nfit_flush_probe(), replace it with init_completion().

You completely fail to explain WHY.

Thanks,

	tglx

 
> Signed-off-by: Boqun Feng <boqun.feng@gmail.com>
> ---
>  drivers/acpi/nfit/core.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/acpi/nfit/core.c b/drivers/acpi/nfit/core.c
> index 19182d091587..1893e416e7c0 100644
> --- a/drivers/acpi/nfit/core.c
> +++ b/drivers/acpi/nfit/core.c
> @@ -2884,7 +2884,7 @@ static int acpi_nfit_flush_probe(struct nvdimm_bus_descriptor *nd_desc)
>  	 * need to be interruptible while waiting.
>  	 */
>  	INIT_WORK_ONSTACK(&flush.work, flush_probe);
> -	COMPLETION_INITIALIZER_ONSTACK(flush.cmp);
> +	init_completion(&flush.cmp);
>  	queue_work(nfit_wq, &flush.work);
>  	mutex_unlock(&acpi_desc->init_mutex);
>  
> -- 
> 2.14.1
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
