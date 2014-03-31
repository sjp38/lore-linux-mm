Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f46.google.com (mail-oa0-f46.google.com [209.85.219.46])
	by kanga.kvack.org (Postfix) with ESMTP id 1D1816B0031
	for <linux-mm@kvack.org>; Mon, 31 Mar 2014 14:35:38 -0400 (EDT)
Received: by mail-oa0-f46.google.com with SMTP id i7so9851896oag.33
        for <linux-mm@kvack.org>; Mon, 31 Mar 2014 11:35:37 -0700 (PDT)
Received: from qmta09.emeryville.ca.mail.comcast.net (qmta09.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:96])
        by mx.google.com with ESMTP id ft3si29968090igd.6.2014.03.31.11.35.36
        for <linux-mm@kvack.org>;
        Mon, 31 Mar 2014 11:35:37 -0700 (PDT)
Date: Mon, 31 Mar 2014 13:35:34 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2] mm: convert some level-less printks to pr_*
In-Reply-To: <1395942859-11611-2-git-send-email-mitchelh@codeaurora.org>
Message-ID: <alpine.DEB.2.10.1403311334060.3313@nuc>
References: <1395942859-11611-1-git-send-email-mitchelh@codeaurora.org> <1395942859-11611-2-git-send-email-mitchelh@codeaurora.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mitchel Humpherys <mitchelh@codeaurora.org>
Cc: Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Joe Perches <joe@perches.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 27 Mar 2014, Mitchel Humpherys wrote:

> diff --git a/mm/slub.c b/mm/slub.c
> index 25f14ad8f8..9f109e6756 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -9,6 +9,8 @@
>   * (C) 2011 Linux Foundation, Christoph Lameter
>   */
>
> +#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt

This is implicitly used by some macros? If so then please define this
elsewhere. I do not see any use in slub.c of this one.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
