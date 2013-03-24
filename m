Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 7FCB66B00F4
	for <linux-mm@kvack.org>; Sun, 24 Mar 2013 03:43:36 -0400 (EDT)
Received: by mail-ea0-f175.google.com with SMTP id o10so1879901eaj.6
        for <linux-mm@kvack.org>; Sun, 24 Mar 2013 00:43:34 -0700 (PDT)
Date: Sun, 24 Mar 2013 08:43:31 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [patch] mm: speedup in __early_pfn_to_nid
Message-ID: <20130324074331.GA12939@gmail.com>
References: <20130318155619.GA18828@sgi.com>
 <20130321105516.GC18484@gmail.com>
 <alpine.DEB.2.02.1303211139110.3775@chino.kir.corp.google.com>
 <20130322072532.GC10608@gmail.com>
 <20130323152948.GA3036@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130323152948.GA3036@sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russ Anderson <rja@sgi.com>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com


* Russ Anderson <rja@sgi.com> wrote:

> --- linux.orig/mm/page_alloc.c	2013-03-19 16:09:03.736450861 -0500
> +++ linux/mm/page_alloc.c	2013-03-22 17:07:43.895405617 -0500
> @@ -4161,10 +4161,23 @@ int __meminit __early_pfn_to_nid(unsigne
>  {
>  	unsigned long start_pfn, end_pfn;
>  	int i, nid;
> +	/*
> +	   NOTE: The following SMP-unsafe globals are only used early
> +	   in boot when the kernel is running single-threaded.
> +	 */
> +	static unsigned long last_start_pfn, last_end_pfn;
> +	static int last_nid;

I guess I'm the nitpicker of the week:

please use the customary (multi-line) comment style:

  /*
   * Comment .....
   * ...... goes here.
   */

specified in Documentation/CodingStyle.

Thanks,

        Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
