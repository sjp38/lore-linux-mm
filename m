Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 610546B0031
	for <linux-mm@kvack.org>; Tue, 11 Feb 2014 16:21:41 -0500 (EST)
Received: by mail-pd0-f169.google.com with SMTP id v10so8081133pde.0
        for <linux-mm@kvack.org>; Tue, 11 Feb 2014 13:21:41 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id tq3si20241975pab.154.2014.02.11.13.21.40
        for <linux-mm@kvack.org>;
        Tue, 11 Feb 2014 13:21:40 -0800 (PST)
Date: Tue, 11 Feb 2014 13:21:37 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCHv3 1/2] mm/memblock: add memblock_get_current_limit
Message-Id: <20140211132137.14af32f551f12630b1629f50@linux-foundation.org>
In-Reply-To: <1392153265-14439-2-git-send-email-lauraa@codeaurora.org>
References: <1392153265-14439-1-git-send-email-lauraa@codeaurora.org>
	<1392153265-14439-2-git-send-email-lauraa@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Leif Lindholm <leif.lindholm@linaro.org>, Grygorii Strashko <grygorii.strashko@ti.com>, Catalin Marinas <catalin.marinas@arm.com>, Rob Herring <robherring2@gmail.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Nicolas Pitre <nicolas.pitre@linaro.org>, Santosh Shilimkar <santosh.shilimkar@ti.com>

On Tue, 11 Feb 2014 13:14:24 -0800 Laura Abbott <lauraa@codeaurora.org> wrote:

> Appart from setting the limit of memblock, it's also useful to be able
> to get the limit to avoid recalculating it every time. Add the function
> to do so.
> 
> Acked-by: Catalin Marinas <catalin.marinas@arm.com>
> Acked-by: Santosh Shilimkar <santosh.shilimkar@ti.com>
> Signed-off-by: Laura Abbott <lauraa@codeaurora.org>

Please add my acked-by to this.  You might also add a note that I do not ack
your spelling of "apart" ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
