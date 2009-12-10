Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 043166B003D
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 07:59:49 -0500 (EST)
Message-ID: <4B20EF88.7050402@redhat.com>
Date: Thu, 10 Dec 2009 07:54:32 -0500
From: Larry Woodman <lwoodman@redhat.com>
Reply-To: lwoodman@redhat.com
MIME-Version: 1.0
Subject: Re: [RFC][PATCH v2  4/8] Replace page_referenced() with wipe_page_reference()
References: <20091210154822.2550.A69D9226@jp.fujitsu.com> <20091210163123.255C.A69D9226@jp.fujitsu.com>
In-Reply-To: <20091210163123.255C.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro wrote:
> @@ -578,7 +577,9 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>
> +		struct page_reference_context refctx = {
> +			.is_page_locked = 1,
>
>   *
> @@ -1289,7 +1291,6 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
>
> +		struct page_reference_context refctx = {
> +			.is_page_locked = 0,
> +		};
> +
>   
are these whole structs properly initialized on the kernel stack?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
