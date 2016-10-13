Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9E10F6B0069
	for <linux-mm@kvack.org>; Thu, 13 Oct 2016 14:16:24 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id z65so118383811itc.2
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 11:16:24 -0700 (PDT)
Received: from resqmta-po-12v.sys.comcast.net (resqmta-po-12v.sys.comcast.net. [2001:558:fe16:19:96:114:154:171])
        by mx.google.com with ESMTPS id x71si9208623ioe.160.2016.10.13.11.16.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Oct 2016 11:16:24 -0700 (PDT)
Date: Thu, 13 Oct 2016 13:16:21 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Rewording language in mbind(2) to "threads" not "processes"
In-Reply-To: <f3c4ca9d-a880-5244-e06e-db4725e4d945@gmail.com>
Message-ID: <alpine.DEB.2.20.1610131314020.3176@east.gentwo.org>
References: <f3c4ca9d-a880-5244-e06e-db4725e4d945@gmail.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Cc: Piotr Kwapulinski <kwapulinski.piotr@gmail.com>, mhocko@kernel.org, mgorman@techsingularity.net, a.p.zijlstra@chello.nl, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-man@vger.kernel.org, Brice Goglin <Brice.Goglin@inria.fr>

On Thu, 13 Oct 2016, Michael Kerrisk (man-pages) wrote:

> @@ -100,7 +100,10 @@ If, however, the shared memory region was created with the
>  .B SHM_HUGETLB
>  flag,
>  the huge pages will be allocated according to the policy specified
> -only if the page allocation is caused by the process that calls
> +only if the page allocation is caused by the thread that calls
> +.\"
> +.\" ??? Is it correct to change "process" to "thread" in the preceding line?

No leave it as process. Pages get one map refcount per page table
that references them (meaning a process). More than one map refcount means
that multiple processes have mapped the page.

> @@ -300,7 +303,10 @@ is specified in
>  .IR flags ,
>  then the kernel will attempt to move all the existing pages
>  in the memory range so that they follow the policy.
> -Pages that are shared with other processes will not be moved.
> +Pages that are shared with other threads will not be moved.
> +.\"
> +.\" ??? Is it correct to change "processes" to "threads" in the preceding line?
> +.\"

Leave it. Same as before.

>  If
>  then the kernel will attempt to move all existing pages in the memory range
> -regardless of whether other processes use the pages.
> -The calling process must be privileged
> +regardless of whether other threads use the pages.
> +.\"
> +.\" ??? Is it correct to change "processes" to "threads" in the preceding line?
> +.\"

Leave as process.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
