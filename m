Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 800496B0005
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 07:11:05 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id t8so75636030oif.2
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 04:11:05 -0700 (PDT)
Received: from emea01-db3-obe.outbound.protection.outlook.com (mail-db3on0132.outbound.protection.outlook.com. [157.55.234.132])
        by mx.google.com with ESMTPS id t190si19556249oih.207.2016.06.16.04.11.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 16 Jun 2016 04:11:04 -0700 (PDT)
Date: Thu, 16 Jun 2016 14:10:53 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 04/13] mm: Track NR_KERNEL_STACK in pages instead of
 number of stacks
Message-ID: <20160616111053.GA13143@esperanza>
References: <cover.1466036668.git.luto@kernel.org>
 <24279d4009c821de64109055665429fad2a7bff7.1466036668.git.luto@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <24279d4009c821de64109055665429fad2a7bff7.1466036668.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, x86@kernel.org, Borislav Petkov <bp@alien8.de>, Nadav Amit <nadav.amit@gmail.com>, Kees Cook <keescook@chromium.org>, Brian Gerst <brgerst@gmail.com>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Linus Torvalds <torvalds@linux-foundation.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org

On Wed, Jun 15, 2016 at 05:28:26PM -0700, Andy Lutomirski wrote:
...
> @@ -225,7 +225,8 @@ static void account_kernel_stack(struct thread_info *ti, int account)
>  {
>  	struct zone *zone = page_zone(virt_to_page(ti));
>  
> -	mod_zone_page_state(zone, NR_KERNEL_STACK, account);
> +	mod_zone_page_state(zone, NR_KERNEL_STACK,
> +			    THREAD_SIZE / PAGE_SIZE * account);

It won't work if THREAD_SIZE < PAGE_SIZE. Is there an arch with such a
thread size, anyway? If no, we should probably drop thread_info_cache.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
