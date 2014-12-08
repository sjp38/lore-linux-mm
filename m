Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id E8A1D6B006C
	for <linux-mm@kvack.org>; Mon,  8 Dec 2014 06:50:38 -0500 (EST)
Received: by mail-wg0-f41.google.com with SMTP id y19so5955171wgg.14
        for <linux-mm@kvack.org>; Mon, 08 Dec 2014 03:50:38 -0800 (PST)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.227])
        by mx.google.com with ESMTP id v7si9435997wiy.8.2014.12.08.03.50.38
        for <linux-mm@kvack.org>;
        Mon, 08 Dec 2014 03:50:38 -0800 (PST)
Date: Mon, 8 Dec 2014 13:50:32 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm:add VM_BUG_ON() for page_mapcount()
Message-ID: <20141208115032.GB28846@node.dhcp.inet.fi>
References: <35FD53F367049845BC99AC72306C23D103E688B313EE@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E688B313F1@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E688B313F5@CNBJMBX05.corpusers.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <35FD53F367049845BC99AC72306C23D103E688B313F5@CNBJMBX05.corpusers.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Cc: "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, "'linux-arm-kernel@lists.infradead.org'" <linux-arm-kernel@lists.infradead.org>, "'akpm@linux-foundation.org'" <akpm@linux-foundation.org>, "'riel@redhat.com'" <riel@redhat.com>, "'nasa4836@gmail.com'" <nasa4836@gmail.com>, "'sasha.levin@oracle.com'" <sasha.levin@oracle.com>

On Mon, Dec 08, 2014 at 03:47:47PM +0800, Wang, Yalin wrote:
> This patch add VM_BUG_ON() for slab page,
> because _mapcount is an union with slab struct in struct page,
> avoid access _mapcount if this page is a slab page.
> Also remove the unneeded bracket.
> 
> Signed-off-by: Yalin Wang <yalin.wang@sonymobile.com>
> ---
>  include/linux/mm.h | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 11b65cf..34124c4 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -373,7 +373,8 @@ static inline void reset_page_mapcount(struct page *page)
>  
>  static inline int page_mapcount(struct page *page)
>  {
> -	return atomic_read(&(page)->_mapcount) + 1;
> +	VM_BUG_ON(PageSlab(page));

VM_BUG_ON_PAGE(), please.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
