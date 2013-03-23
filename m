Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 74D3C6B0002
	for <linux-mm@kvack.org>; Sat, 23 Mar 2013 18:24:25 -0400 (EDT)
Received: by mail-oa0-f44.google.com with SMTP id h1so5350491oag.17
        for <linux-mm@kvack.org>; Sat, 23 Mar 2013 15:24:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130323152948.GA3036@sgi.com>
References: <20130318155619.GA18828@sgi.com> <20130321105516.GC18484@gmail.com>
 <alpine.DEB.2.02.1303211139110.3775@chino.kir.corp.google.com>
 <20130322072532.GC10608@gmail.com> <20130323152948.GA3036@sgi.com>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Sat, 23 Mar 2013 18:24:04 -0400
Message-ID: <CAHGf_=qgsga4Juj8uNnfbmOZYtYhcQbqngbFDWg9=B-1nc1HSw@mail.gmail.com>
Subject: Re: [patch] mm: speedup in __early_pfn_to_nid
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russ Anderson <rja@sgi.com>
Cc: Ingo Molnar <mingo@kernel.org>, David Rientjes <rientjes@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>

> --- linux.orig/mm/page_alloc.c  2013-03-19 16:09:03.736450861 -0500
> +++ linux/mm/page_alloc.c       2013-03-22 17:07:43.895405617 -0500
> @@ -4161,10 +4161,23 @@ int __meminit __early_pfn_to_nid(unsigne
>  {
>         unsigned long start_pfn, end_pfn;
>         int i, nid;
> +       /*
> +          NOTE: The following SMP-unsafe globals are only used early
> +          in boot when the kernel is running single-threaded.
> +        */
> +       static unsigned long last_start_pfn, last_end_pfn;
> +       static int last_nid;

Why don't you mark them __meminitdata? They seems freeable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
