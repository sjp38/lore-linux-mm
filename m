Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id D3A4A6B005A
	for <linux-mm@kvack.org>; Fri,  8 Jun 2012 16:16:40 -0400 (EDT)
Received: by vbkv13 with SMTP id v13so686877vbk.14
        for <linux-mm@kvack.org>; Fri, 08 Jun 2012 13:16:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1339182919-11432-3-git-send-email-levinsasha928@gmail.com>
References: <1339182919-11432-1-git-send-email-levinsasha928@gmail.com>
	<1339182919-11432-3-git-send-email-levinsasha928@gmail.com>
Date: Fri, 8 Jun 2012 23:16:39 +0300
Message-ID: <CAOJsxLG2H_G3CrmqNSxEnYRB+mACRyeG4dOQZ6wasXV1V0vGYg@mail.gmail.com>
Subject: Re: [PATCH v2 02/10] mm: frontswap: trivial coding convention issues
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: dan.magenheimer@oracle.com, konrad.wilk@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jun 8, 2012 at 10:15 PM, Sasha Levin <levinsasha928@gmail.com> wrot=
e:
> Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
> ---
> =A0mm/frontswap.c | =A0 =A05 +++--
> =A01 files changed, 3 insertions(+), 2 deletions(-)
>
> diff --git a/mm/frontswap.c b/mm/frontswap.c
> index 557e8af4..b619d29 100644
> --- a/mm/frontswap.c
> +++ b/mm/frontswap.c
> @@ -150,6 +150,7 @@ int __frontswap_store(struct page *page)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0inc_frontswap_failed_stores();
> =A0 =A0 =A0 =A0} else
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0inc_frontswap_failed_stores();
> + =A0 =A0 =A0 }

This looks wrong. Did you compile it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
