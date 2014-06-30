Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f42.google.com (mail-oa0-f42.google.com [209.85.219.42])
	by kanga.kvack.org (Postfix) with ESMTP id 5196F6B0035
	for <linux-mm@kvack.org>; Mon, 30 Jun 2014 19:05:51 -0400 (EDT)
Received: by mail-oa0-f42.google.com with SMTP id eb12so9756889oac.1
        for <linux-mm@kvack.org>; Mon, 30 Jun 2014 16:05:51 -0700 (PDT)
Received: from mail-ob0-x234.google.com (mail-ob0-x234.google.com [2607:f8b0:4003:c01::234])
        by mx.google.com with ESMTPS id eb3si27875303oeb.17.2014.06.30.16.05.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 30 Jun 2014 16:05:50 -0700 (PDT)
Received: by mail-ob0-f180.google.com with SMTP id vb8so9496569obc.25
        for <linux-mm@kvack.org>; Mon, 30 Jun 2014 16:05:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.02.1406301549020.23648@chino.kir.corp.google.com>
References: <53aa90d2.Yd3WgTmElIsuiwuV%fengguang.wu@intel.com>
	<20140625100213.GA1866@localhost>
	<53AAB2D3.2050809@oracle.com>
	<alpine.DEB.2.02.1406251543080.4592@chino.kir.corp.google.com>
	<53AB7F0B.5050900@oracle.com>
	<alpine.DEB.2.02.1406252310560.3960@chino.kir.corp.google.com>
	<53ABBEA0.1010307@oracle.com>
	<20140626074735.GA24582@localhost>
	<alpine.DEB.2.02.1406301549020.23648@chino.kir.corp.google.com>
Date: Mon, 30 Jun 2014 16:05:50 -0700
Message-ID: <CAGXu5jKew5uzGHFs9fhOD4HTWAv+uq4num+0U_7nKN0MTz0OPg@mail.gmail.com>
Subject: Re: [patch] binfmt_elf.c: use get_random_int() to fix entropy
 depleting fix
From: Kees Cook <keescook@chromium.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, Jeff Liu <jeff.liu@oracle.com>, linux-mm@kvack.org

On Mon, Jun 30, 2014 at 3:52 PM, David Rientjes <rientjes@google.com> wrote:
> The type of size_t on am33 is unsigned int for gcc major versions >= 4.
>
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  fs/binfmt_elf.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
> --- a/fs/binfmt_elf.c
> +++ b/fs/binfmt_elf.c
> @@ -155,7 +155,7 @@ static void get_atrandom_bytes(unsigned char *buf, size_t nbytes)
>
>         while (nbytes) {
>                 unsigned int random_variable;
> -               size_t chunk = min(nbytes, sizeof(random_variable));
> +               size_t chunk = min(nbytes, (size_t)sizeof(random_variable));
>
>                 random_variable = get_random_int();
>                 memcpy(p, &random_variable, chunk);

If you have the compiler warning still, that's handy to include in the
commit message. Regardless, seems good to me.

Acked-by: Kees Cook <keescook@chromium.org>

Thanks!

-Kees

-- 
Kees Cook
Chrome OS Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
