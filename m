Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id CCCB66B0124
	for <linux-mm@kvack.org>; Wed, 22 Jul 2009 15:02:47 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 8C97982C5D2
	for <linux-mm@kvack.org>; Wed, 22 Jul 2009 15:22:38 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id tcA-lqKbF5uR for <linux-mm@kvack.org>;
	Wed, 22 Jul 2009 15:22:38 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id D410082C5D4
	for <linux-mm@kvack.org>; Wed, 22 Jul 2009 15:22:33 -0400 (EDT)
Date: Wed, 22 Jul 2009 15:02:30 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [patch 5/4] mm: document is_page_cache_freeable()
In-Reply-To: <20090722175417.GA7059@cmpxchg.org>
Message-ID: <alpine.DEB.1.10.0907221500440.29748@gentwo.org>
References: <1248166594-8859-1-git-send-email-hannes@cmpxchg.org> <1248166594-8859-4-git-send-email-hannes@cmpxchg.org> <alpine.DEB.1.10.0907221220350.3588@gentwo.org> <20090722175031.GA3484@cmpxchg.org> <20090722175417.GA7059@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


>  static inline int is_page_cache_freeable(struct page *page)
>  {
> +	/*
> +	 * A freeable page cache page is referenced only by the caller
> +	 * that isolated the page, the page cache itself and

The page cache "itself"? This is the radix tree reference right?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
