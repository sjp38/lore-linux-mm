Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f41.google.com (mail-yh0-f41.google.com [209.85.213.41])
	by kanga.kvack.org (Postfix) with ESMTP id DC4F96B0035
	for <linux-mm@kvack.org>; Wed, 18 Dec 2013 14:33:30 -0500 (EST)
Received: by mail-yh0-f41.google.com with SMTP id f11so56331yha.0
        for <linux-mm@kvack.org>; Wed, 18 Dec 2013 11:33:30 -0800 (PST)
Received: from fujitsu25.fnanic.fujitsu.com (fujitsu25.fnanic.fujitsu.com. [192.240.6.15])
        by mx.google.com with ESMTPS id s6si823746yho.89.2013.12.18.11.33.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 18 Dec 2013 11:33:29 -0800 (PST)
From: Motohiro Kosaki <Motohiro.Kosaki@us.fujitsu.com>
Date: Wed, 18 Dec 2013 11:31:53 -0800
Subject: RE: [PATCH] mm: remove BUG_ON() from mlock_vma_page()
Message-ID: <6B2BA408B38BA1478B473C31C3D2074E2AFAD01380@SV-EXCHANGE1.Corp.FC.LOCAL>
References: <1387327369-18806-1-git-send-email-bob.liu@oracle.com>
In-Reply-To: <1387327369-18806-1-git-send-email-bob.liu@oracle.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "walken@google.com" <walken@google.com>, Motohiro Kosaki JP <kosaki.motohiro@jp.fujitsu.com>, "riel@redhat.com" <riel@redhat.com>, "sasha.levin@oracle.com" <sasha.levin@oracle.com>, "vbabka@suse.cz" <vbabka@suse.cz>, "stable@kernel.org" <stable@kernel.org>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, Bob Liu <bob.liu@oracle.com>

>=20
> diff --git a/mm/mlock.c b/mm/mlock.c
> index d480cd6..5488d44 100644
> --- a/mm/mlock.c
> +++ b/mm/mlock.c
> @@ -79,8 +79,6 @@ void clear_page_mlock(struct page *page)
>   */
>  void mlock_vma_page(struct page *page)
>  {
> -	BUG_ON(!PageLocked(page));
> -
>  	if (!TestSetPageMlocked(page)) {
>  		mod_zone_page_state(page_zone(page), NR_MLOCK,
>  				    hpage_nr_pages(page));
> --
> 1.7.10.4

Acked-by: KOSAKI Motohiro <Kosaki.motohiro@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
