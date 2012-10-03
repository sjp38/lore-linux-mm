Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 130926B005D
	for <linux-mm@kvack.org>; Tue,  2 Oct 2012 20:43:26 -0400 (EDT)
Received: by obcva7 with SMTP id va7so8401866obc.14
        for <linux-mm@kvack.org>; Tue, 02 Oct 2012 17:43:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20121002234934.GA9194@www.outflux.net>
References: <20121002234934.GA9194@www.outflux.net>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Tue, 2 Oct 2012 20:43:04 -0400
Message-ID: <CAHGf_=q3_EBCx+=ZL1cY7Q3=rQOiEhK3F7X-0fHd3A5_S+GUSg@mail.gmail.com>
Subject: Re: [PATCH] mm: use %pK for /proc/vmallocinfo
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, Joe Perches <joe@perches.com>, Kautuk Consul <consul.kautuk@gmail.com>, linux-mm@kvack.org, Brad Spengler <spender@grsecurity.net>

On Tue, Oct 2, 2012 at 7:49 PM, Kees Cook <keescook@chromium.org> wrote:
> In the paranoid case of sysctl kernel.kptr_restrict=2, mask the kernel
> virtual addresses in /proc/vmallocinfo too.
>
> Reported-by: Brad Spengler <spender@grsecurity.net>
> Signed-off-by: Kees Cook <keescook@chromium.org>
> ---
>  mm/vmalloc.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index 2bb90b1..9c871db 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -2572,7 +2572,7 @@ static int s_show(struct seq_file *m, void *p)
>  {
>         struct vm_struct *v = p;
>
> -       seq_printf(m, "0x%p-0x%p %7ld",
> +       seq_printf(m, "0x%pK-0x%pK %7ld",
>                 v->addr, v->addr + v->size, v->size);

Looks good.
Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
