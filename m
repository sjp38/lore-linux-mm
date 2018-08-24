Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7AD336B2F7F
	for <linux-mm@kvack.org>; Fri, 24 Aug 2018 08:57:46 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id 13-v6so7559783oiq.1
        for <linux-mm@kvack.org>; Fri, 24 Aug 2018 05:57:46 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id p184-v6si5265372oih.415.2018.08.24.05.57.45
        for <linux-mm@kvack.org>;
        Fri, 24 Aug 2018 05:57:45 -0700 (PDT)
Date: Fri, 24 Aug 2018 13:57:40 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH] kmemleak: Add option to print warnings to dmesg
Message-ID: <20180824125740.wy3fmtowicglyqng@armageddon.cambridge.arm.com>
References: <20180824124011.22879-1-vincent.whitchurch@axis.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180824124011.22879-1-vincent.whitchurch@axis.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vincent Whitchurch <vincent.whitchurch@axis.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vincent Whitchurch <rabinv@axis.com>

On Fri, Aug 24, 2018 at 02:40:11PM +0200, Vincent Whitchurch wrote:
> diff --git a/mm/kmemleak.c b/mm/kmemleak.c
> index 9a085d525bbc..61ba47a357fc 100644
> --- a/mm/kmemleak.c
> +++ b/mm/kmemleak.c
> @@ -311,6 +311,9 @@ static void hex_dump_object(struct seq_file *seq,
>  	const u8 *ptr = (const u8 *)object->pointer;
>  	size_t len;
>  
> +	if (!seq)
> +		return;
> +
>  	/* limit the number of lines to HEX_MAX_LINES */
>  	len = min_t(size_t, object->size, HEX_MAX_LINES * HEX_ROW_SIZE);
>  

We have a print_hex_dump() function you could use here instead of
skipping it. Sometimes such information is useful to capture part of the
object state.

-- 
Catalin
