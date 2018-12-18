Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id C81918E0001
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 07:47:52 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id m13so11807306pls.15
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 04:47:52 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id o7si12222809pgg.118.2018.12.18.04.47.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 18 Dec 2018 04:47:51 -0800 (PST)
Date: Tue, 18 Dec 2018 04:47:10 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] Export mm_update_next_owner function for unuse_mm.
Message-ID: <20181218124710.GU10600@bombadil.infradead.org>
References: <1545104531-30658-1-git-send-email-gchen.guomin@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1545104531-30658-1-git-send-email-gchen.guomin@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gchen.guomin@gmail.com
Cc: "Michael S. Tsirkin" <mst@redhat.com>, Jason Wang <jasowang@redhat.com>, Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, "Luis R. Rodriguez" <mcgrof@kernel.org>, guominchen@tencent.com, "Eric W. Biederman" <ebiederm@xmission.com>, Dominik Brodowski <linux@dominikbrodowski.net>, Arnd Bergmann <arnd@arndb.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Dec 18, 2018 at 11:42:11AM +0800, gchen.guomin@gmail.com wrote:
> +EXPORT_SYMBOL(mm_update_next_owner);

Unless you've figured out how to build mmu_context.c as a module, you
don't need to EXPORT the symbol.  Just the below hunk is enough.

> diff --git a/mm/mmu_context.c b/mm/mmu_context.c
> index 3e612ae..9eb81aa 100644
> --- a/mm/mmu_context.c
> +++ b/mm/mmu_context.c
> @@ -60,5 +60,6 @@ void unuse_mm(struct mm_struct *mm)
>  	/* active_mm is still 'mm' */
>  	enter_lazy_tlb(mm, tsk);
>  	task_unlock(tsk);
> +	mm_update_next_owner(mm);
>  }
>  EXPORT_SYMBOL_GPL(unuse_mm);
> -- 
> 1.8.3.1
> 
