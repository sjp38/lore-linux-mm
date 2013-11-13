Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 5A8D16B009A
	for <linux-mm@kvack.org>; Wed, 13 Nov 2013 14:21:02 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id kx10so111780pab.29
        for <linux-mm@kvack.org>; Wed, 13 Nov 2013 11:21:01 -0800 (PST)
Received: from psmtp.com ([74.125.245.175])
        by mx.google.com with SMTP id cx4si24612659pbc.299.2013.11.13.11.20.59
        for <linux-mm@kvack.org>;
        Wed, 13 Nov 2013 11:21:00 -0800 (PST)
Received: by mail-oa0-f47.google.com with SMTP id i7so1018601oag.34
        for <linux-mm@kvack.org>; Wed, 13 Nov 2013 11:20:58 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.02.1311121811310.29891@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1311121811310.29891@chino.kir.corp.google.com>
Date: Wed, 13 Nov 2013 11:20:58 -0800
Message-ID: <CAGXu5jKXuATW-Yy_C+5Cz7NPAKxW7VO_b=OzdXKvjGurG6BCGw@mail.gmail.com>
Subject: Re: [patch -mm] mm, mempolicy: silence gcc warning
From: Kees Cook <keescook@chromium.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org

On Tue, Nov 12, 2013 at 6:12 PM, David Rientjes <rientjes@google.com> wrote:
> Fengguang Wu reports that compiling mm/mempolicy.c results in a warning:
>
>         mm/mempolicy.c: In function 'mpol_to_str':
>         mm/mempolicy.c:2878:2: error: format not a string literal and no format arguments
>
> Kees says this is because he is using -Wformat-security.
>
> Silence the warning.
>
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Suggested-by: Kees Cook <keescook@chromium.org>
> Signed-off-by: David Rientjes <rientjes@google.com>

Thanks for helping silence my -Wformat-security warning checks. :)

Acked-by: Kees Cook <keescook@chromium.org>

-Kees

> ---
>  mm/mempolicy.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -2950,7 +2950,7 @@ void mpol_to_str(char *buffer, int maxlen, struct mempolicy *pol)
>                 return;
>         }
>
> -       p += snprintf(p, maxlen, policy_modes[mode]);
> +       p += snprintf(p, maxlen, "%s", policy_modes[mode]);
>
>         if (flags & MPOL_MODE_FLAGS) {
>                 p += snprintf(p, buffer + maxlen - p, "=");



-- 
Kees Cook
Chrome OS Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
