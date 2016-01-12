Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 0292E828DF
	for <linux-mm@kvack.org>; Tue, 12 Jan 2016 17:09:41 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id cy9so346416998pac.0
        for <linux-mm@kvack.org>; Tue, 12 Jan 2016 14:09:40 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id m68si38809094pfj.133.2016.01.12.14.09.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jan 2016 14:09:40 -0800 (PST)
Date: Tue, 12 Jan 2016 14:09:39 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v1] mm: soft-offline: check return value in second
 __get_any_page() call
Message-Id: <20160112140939.26df8a425422341bb899ee6f@linux-foundation.org>
In-Reply-To: <20160112032932.GA8314@hori1.linux.bs1.fc.nec.co.jp>
References: <1452237748-10822-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	<20160108075158.GA28640@hori1.linux.bs1.fc.nec.co.jp>
	<20160108153626.16332573d71cdfcdbc1637cd@linux-foundation.org>
	<20160112032932.GA8314@hori1.linux.bs1.fc.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andi Kleen <andi@firstfloor.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Tue, 12 Jan 2016 03:29:35 +0000 Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:

> > I don't understand what you're asking for.  Please be very
> > specific and carefully identify patches by filename or Subject:.
> 
> OK, so what I really wanted is that (1) applying this patch just before
> http://ozlabs.org/~akpm/mmots/broken-out/mm-hwpoison-adjust-for-new-thp-refcounting.patch
> and (2) removing the following chunk from the mm-hwpoison-adjust-for-new-thp-refcounting.patch:
> 
> @@ -1575,7 +1540,7 @@ static int get_any_page(struct page *pag
>  		 * Did it turn free?
>  		 */
>  		ret = __get_any_page(page, pfn, 0);
> -		if (!PageLRU(page)) {
> +		if (ret == 1 && !PageLRU(page)) {
>  			/* Drop page reference which is from __get_any_page() */
>  			put_hwpoison_page(page);
>  			pr_info("soft_offline: %#lx: unknown non LRU page type %lx\n",

Not a problem, thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
