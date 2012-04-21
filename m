Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id D65526B004D
	for <linux-mm@kvack.org>; Sat, 21 Apr 2012 19:48:48 -0400 (EDT)
Received: by pbcup15 with SMTP id up15so2979384pbc.14
        for <linux-mm@kvack.org>; Sat, 21 Apr 2012 16:48:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1335015755-2881-1-git-send-email-rajman.mekaco@gmail.com>
References: <1335015755-2881-1-git-send-email-rajman.mekaco@gmail.com>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Sat, 21 Apr 2012 19:48:27 -0400
Message-ID: <CAHGf_=ovyXxNwc8o=MjL9-6eReCA2UzDvLeLMqEHVPxiLiKOPQ@mail.gmail.com>
Subject: Re: [PATCH 1/1] mmap.c: find_vma: remove unnecessary if(mm) check
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rajman Mekaco <rajman.mekaco@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Al Viro <viro@zeniv.linux.org.uk>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kautuk Consul <consul.kautuk@gmail.com>

On Sat, Apr 21, 2012 at 9:42 AM, Rajman Mekaco <rajman.mekaco@gmail.com> wrote:
> The if(mm) check is not required in find_vma, as the kernel
> code calls find_vma only when it is absolutely sure that the
> mm_struct arg to it is non-NULL.
>
> Removing the if(mm) check and adding the a WARN_ONCE(!mm)
> for now.
> This will serve the purpose of mandating that the execution
> context(user-mode/kernel-mode) be known before find_vma is called.
> Also fixed 2 checkpatch.pl errors in the declaration
> of the rb_node and vma_tmp local variables.
>
> I was browsing through the internet and read a discussion
> at https://lkml.org/lkml/2012/3/27/342 which discusses removal
> of the validation check within find_vma.
> Since no-one responded, I decided to send this patch with Andrew's
> suggestions.
>
> Signed-off-by: Rajman Mekaco <rajman.mekaco@gmail.com>
> Cc: Kautuk Consul <consul.kautuk@gmail.com>

Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
