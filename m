Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f46.google.com (mail-qa0-f46.google.com [209.85.216.46])
	by kanga.kvack.org (Postfix) with ESMTP id 7A6696B0037
	for <linux-mm@kvack.org>; Thu,  3 Jul 2014 14:14:24 -0400 (EDT)
Received: by mail-qa0-f46.google.com with SMTP id i13so495687qae.5
        for <linux-mm@kvack.org>; Thu, 03 Jul 2014 11:14:24 -0700 (PDT)
Received: from cam-admin0.cambridge.arm.com (cam-admin0.cambridge.arm.com. [217.140.96.50])
        by mx.google.com with ESMTP id do2si38020676qcb.21.2014.07.03.11.14.22
        for <linux-mm@kvack.org>;
        Thu, 03 Jul 2014 11:14:23 -0700 (PDT)
Date: Thu, 3 Jul 2014 19:14:25 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCHv4 2/5] lib/genalloc.c: Add genpool range check function
Message-ID: <20140703181425.GK17372@arm.com>
References: <1404324218-4743-1-git-send-email-lauraa@codeaurora.org>
 <1404324218-4743-3-git-send-email-lauraa@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1404324218-4743-3-git-send-email-lauraa@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>
Cc: Catalin Marinas <Catalin.Marinas@arm.com>, David Riley <davidriley@chromium.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Ritesh Harjain <ritesh.harjani@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed, Jul 02, 2014 at 07:03:35PM +0100, Laura Abbott wrote:
> 
> After allocating an address from a particular genpool,
> there is no good way to verify if that address actually
> belongs to a genpool. Introduce addr_in_gen_pool which
> will return if an address plus size falls completely
> within the genpool range.
> 
> Signed-off-by: Laura Abbott <lauraa@codeaurora.org>
> ---

Acked-by: Will Deacon <will.deacon@arm.com>

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
