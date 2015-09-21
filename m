Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id E30326B0254
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 17:31:08 -0400 (EDT)
Received: by qgez77 with SMTP id z77so102121992qge.1
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 14:31:08 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 19si7936458qht.99.2015.09.21.14.31.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Sep 2015 14:31:03 -0700 (PDT)
Date: Mon, 21 Sep 2015 14:31:01 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 33/38] mm/memblock.c: remove invalid check
Message-Id: <20150921143101.09426cd661fe66e65a1c06b5@linux-foundation.org>
In-Reply-To: <1442842450-29769-34-git-send-email-a.hajda@samsung.com>
References: <1442842450-29769-1-git-send-email-a.hajda@samsung.com>
	<1442842450-29769-34-git-send-email-a.hajda@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrzej Hajda <a.hajda@samsung.com>
Cc: linux-kernel@vger.kernel.org, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Alexander Kuleshov <kuleshovmail@gmail.com>, Tony Luck <tony.luck@intel.com>, Wei Yang <weiyang@linux.vnet.ibm.com>, linux-mm@kvack.org

On Mon, 21 Sep 2015 15:34:05 +0200 Andrzej Hajda <a.hajda@samsung.com> wrote:

> Unsigned value cannot be lesser than zero.
> 
> The problem has been detected using proposed semantic patch
> scripts/coccinelle/tests/unsigned_lesser_than_zero.cocci [1].
> 
> [1]: http://permalink.gmane.org/gmane.linux.kernel/2038576
> 
> ...
>
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -837,7 +837,7 @@ void __init_memblock __next_reserved_mem_region(u64 *idx,
>  {
>  	struct memblock_type *type = &memblock.reserved;
>  
> -	if (*idx >= 0 && *idx < type->cnt) {
> +	if (*idx < type->cnt) {

Linus has in the past expressed a preference for retaining checks such
as this.  iirc he finds it clearer.  And perhaps safer if the type
should change in the future.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
