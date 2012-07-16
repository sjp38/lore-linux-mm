Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 7D7896B0074
	for <linux-mm@kvack.org>; Mon, 16 Jul 2012 13:37:18 -0400 (EDT)
Date: Mon, 16 Jul 2012 12:37:16 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/3] mm: correct return value of migrate_pages()
In-Reply-To: <CAAmzW4P0Pa5-gM7mDnqBXCC=g3zk-z_7pXbR7XPM6Tv6CcVJiw@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1207161237060.32319@router.home>
References: <1342455272-32703-1-git-send-email-js1304@gmail.com> <alpine.DEB.2.00.1207161220440.32319@router.home> <CAAmzW4P0Pa5-gM7mDnqBXCC=g3zk-z_7pXbR7XPM6Tv6CcVJiw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: JoonSoo Kim <js1304@gmail.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 17 Jul 2012, JoonSoo Kim wrote:

>
>         for (pass = 0; pass < 10 && retry; pass++) {
>                 retry = 0;
> +               nr_failed = 0;
>
>                 list_for_each_entry_safe(page, page2, from, lru) {
>                         cond_resched();
>
> When I resend with this, could I include "Acked-by: Christoph Lameter
> <cl@linux.com>"?

Sure.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
