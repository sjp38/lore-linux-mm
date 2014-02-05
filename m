Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id AE6F56B0037
	for <linux-mm@kvack.org>; Wed,  5 Feb 2014 17:01:17 -0500 (EST)
Received: by mail-pb0-f50.google.com with SMTP id rq2so920791pbb.23
        for <linux-mm@kvack.org>; Wed, 05 Feb 2014 14:01:17 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id pg10si15129670pbb.354.2014.02.05.14.01.16
        for <linux-mm@kvack.org>;
        Wed, 05 Feb 2014 14:01:16 -0800 (PST)
Date: Wed, 5 Feb 2014 14:01:13 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCHv2 1/2] mm/memblock: add memblock_get_current_limit
Message-Id: <20140205140113.f02dd196c88ad2cf55123b9e@linux-foundation.org>
In-Reply-To: <1391558551-31395-2-git-send-email-lauraa@codeaurora.org>
References: <1391558551-31395-1-git-send-email-lauraa@codeaurora.org>
	<1391558551-31395-2-git-send-email-lauraa@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Leif Lindholm <leif.lindholm@linaro.org>, Grygorii Strashko <grygorii.strashko@ti.com>, Catalin Marinas <catalin.marinas@arm.com>, Rob Herring <robherring2@gmail.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Nicolas Pitre <nicolas.pitre@linaro.org>, Santosh Shilimkar <santosh.shilimkar@ti.com>

On Tue,  4 Feb 2014 16:02:30 -0800 Laura Abbott <lauraa@codeaurora.org> wrote:

> Appart from setting the limit of memblock, it's also useful to be able
> to get the limit to avoid recalculating it every time. Add the function
> to do so.

Looks OK to me.  Your "[PATCHv2 2/2] arm: Get rid of meminfo" did not
make it into my inbox or into my lkml folder, but I found it at
lkml.org so the server did send it.  I'm not sure what's up with that.

Please include [patch 1/2] within or alongside [patch 2/2] so they both
get merged via the same route, which is presumably an arm tree.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
