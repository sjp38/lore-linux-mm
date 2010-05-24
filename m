Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 6EF786B01B0
	for <linux-mm@kvack.org>; Mon, 24 May 2010 14:14:03 -0400 (EDT)
Received: by pzk6 with SMTP id 6so1631279pzk.1
        for <linux-mm@kvack.org>; Mon, 24 May 2010 11:14:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1274150525-2738-1-git-send-email-justinmattock@gmail.com>
References: <1274150525-2738-1-git-send-email-justinmattock@gmail.com>
Date: Mon, 24 May 2010 11:14:01 -0700
Message-ID: <AANLkTilrQZFe07KprlbFeazkfbqzZQXCcvRlCJNb1B6-@mail.gmail.com>
Subject: Re: [PATCH]mm:highmem.h remove obsolete memclear_highpage_flush()
	call.
From: Justin Mattock <justinmattock@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, "Justin P. Mattock" <justinmattock@gmail.com>
List-ID: <linux-mm.kvack.org>

On Mon, May 17, 2010 at 7:42 PM, Justin P. Mattock
<justinmattock@gmail.com> wrote:
> memclear_highpage_flush has been changed over to
> zero_user_page for some time now. I think it's
> safe to say it's o.k. to remove all of it.
> (but correct me if I'm wrong).
>
> Signed-off-by: Justin P. Mattock <justinmattock@gmail.com>
>
>
> ---
> =A0include/linux/highmem.h | =A0 =A06 ------
> =A01 files changed, 0 insertions(+), 6 deletions(-)
>
> diff --git a/include/linux/highmem.h b/include/linux/highmem.h
> index 74152c0..c77f913 100644
> --- a/include/linux/highmem.h
> +++ b/include/linux/highmem.h
> @@ -173,12 +173,6 @@ static inline void zero_user(struct page *page,
> =A0 =A0 =A0 =A0zero_user_segments(page, start, start + size, 0, 0);
> =A0}
>
> -static inline void __deprecated memclear_highpage_flush(struct page *pag=
e,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned int offset, unsign=
ed int size)
> -{
> - =A0 =A0 =A0 zero_user(page, offset, size);
> -}
> -
> =A0#ifndef __HAVE_ARCH_COPY_USER_HIGHPAGE
>
> =A0static inline void copy_user_highpage(struct page *to, struct page *fr=
om,
> --
> 1.6.5.2.180.gc5b3e
>
>

no response on this yet..
is it safe to say this can go in
my reject pile?

--=20
Justin P. Mattock

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
