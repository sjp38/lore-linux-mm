Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id BCFB16B0031
	for <linux-mm@kvack.org>; Mon,  9 Sep 2013 04:48:44 -0400 (EDT)
Date: Mon, 9 Sep 2013 10:51:22 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [patch] filemap: add missing unlock_page
Message-ID: <20130909075121.GA21419@shutemov.name>
References: <20130909081822.8D4DF428001@webmail.sinamail.sina.com.cn>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130909081822.8D4DF428001@webmail.sinamail.sina.com.cn>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@sina.com>
Cc: linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Hillf Danton <dhillf@gmail.com>

On Mon, Sep 09, 2013 at 04:18:22PM +0800, Hillf Danton wrote:
> Unlock and release page before returning error.
> 
> Signed-off-by: Hillf Danton <dhillf@gmail.com>
> ---
> 
> --- a/mm/filemap.c	Mon Sep  9 15:51:28 2013
> +++ b/mm/filemap.c	Mon Sep  9 15:52:54 2013
> @@ -1844,6 +1844,7 @@ retry:
>  	}
>  	err = filler(data, page);
>  	if (err < 0) {
> +		unlock_page(page);
>  		page_cache_release(page);
>  		return ERR_PTR(err);
>  	}

NAK. filler() should unlock the page.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
