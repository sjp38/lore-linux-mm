Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f172.google.com (mail-qc0-f172.google.com [209.85.216.172])
	by kanga.kvack.org (Postfix) with ESMTP id 1AA006B0035
	for <linux-mm@kvack.org>; Wed,  5 Feb 2014 18:19:38 -0500 (EST)
Received: by mail-qc0-f172.google.com with SMTP id c9so1906071qcz.3
        for <linux-mm@kvack.org>; Wed, 05 Feb 2014 15:19:37 -0800 (PST)
Received: from comal.ext.ti.com (comal.ext.ti.com. [198.47.26.152])
        by mx.google.com with ESMTPS id v8si21782542qab.161.2014.02.05.15.19.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 05 Feb 2014 15:19:37 -0800 (PST)
Message-ID: <52F2C700.8070502@ti.com>
Date: Wed, 5 Feb 2014 18:19:28 -0500
From: Santosh Shilimkar <santosh.shilimkar@ti.com>
MIME-Version: 1.0
Subject: Re: [PATCHv2 1/2] mm/memblock: add memblock_get_current_limit
References: <1391558551-31395-1-git-send-email-lauraa@codeaurora.org> <1391558551-31395-2-git-send-email-lauraa@codeaurora.org>
In-Reply-To: <1391558551-31395-2-git-send-email-lauraa@codeaurora.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Leif Lindholm <leif.lindholm@linaro.org>, Grygorii Strashko <grygorii.strashko@ti.com>, Catalin Marinas <catalin.marinas@arm.com>, Rob Herring <robherring2@gmail.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Nicolas Pitre <nicolas.pitre@linaro.org>

On Tuesday 04 February 2014 07:02 PM, Laura Abbott wrote:
> Appart from setting the limit of memblock, it's also useful to be able
> to get the limit to avoid recalculating it every time. Add the function
> to do so.
> 
> Signed-off-by: Laura Abbott <lauraa@codeaurora.org>
> ---
Acked-by: Santosh Shilimkar <santosh.shilimkar@ti.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
