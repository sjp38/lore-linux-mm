Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id E1F826B006E
	for <linux-mm@kvack.org>; Fri,  8 Jun 2012 04:40:37 -0400 (EDT)
Received: by eaan1 with SMTP id n1so1210682eaa.14
        for <linux-mm@kvack.org>; Fri, 08 Jun 2012 01:40:36 -0700 (PDT)
Date: Fri, 8 Jun 2012 10:40:33 +0200
From: Simon Baatz <gmbnomis@gmail.com>
Subject: Re: [PATCH] shmem: replace_page must flush_dcache and others
Message-ID: <20120608084033.GA21818@schnuecks.de>
References: <alpine.LSU.2.00.1205311524160.4512@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1205311524160.4512@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Stephane Marchesin <marcheu@chromium.org>, Andi Kleen <andi@firstfloor.org>, Dave Airlie <airlied@gmail.com>, Daniel Vetter <daniel@ffwll.ch>, Rob Clark <rob.clark@linaro.org>, Cong Wang <xiyou.wangcong@gmail.com>, linux-mm@kvack.org, linux-fsdevel@kernel.org, linux-kernel@vger.kernel.org

Hi Hugh,

On Thu, May 31, 2012 at 03:31:27PM -0700, Hugh Dickins wrote:
> * shmem_replace_page must flush_dcache_page after copy_highpage [akpm]

>  
> -	*pagep = newpage;
>  	page_cache_get(newpage);
>  	copy_highpage(newpage, oldpage);
> +	flush_dcache_page(newpage);
>  

Couldn't we use the lighter flush_kernel_dcache_page() here (like in
fs/exec.c copy_strings())?  If I got this correctly, the page is
copied via the kernel mapping and thus, only the kernel mapping needs
to be flushed.

- Simon

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
