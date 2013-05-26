Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 1FD3F6B008C
	for <linux-mm@kvack.org>; Sun, 26 May 2013 07:45:18 -0400 (EDT)
Received: by mail-ob0-f171.google.com with SMTP id ef5so7063146obb.2
        for <linux-mm@kvack.org>; Sun, 26 May 2013 04:45:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <537407790857e8a5d4db5fb294a909a61be29687.1369529143.git.aquini@redhat.com>
References: <cover.1369529143.git.aquini@redhat.com> <537407790857e8a5d4db5fb294a909a61be29687.1369529143.git.aquini@redhat.com>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Sun, 26 May 2013 07:44:56 -0400
Message-ID: <CAHGf_=qU5nBeya=God5AyG2szvtJJCDd4VOt0TJZBgiEX27Njw@mail.gmail.com>
Subject: Re: [PATCH 01/02] swap: discard while swapping only if SWAP_FLAG_DISCARD_PAGES
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, shli@kernel.org, kzak@redhat.com, Jeff Moyer <jmoyer@redhat.com>, "riel@redhat.com" <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Mel Gorman <mgorman@suse.de>

> +                       /*
> +                        * By flagging sys_swapon, a sysadmin can tell us to
> +                        * either do sinle-time area discards only, or to just
> +                        * perform discards for released swap page-clusters.
> +                        * Now it's time to adjust the p->flags accordingly.
> +                        */
> +                       if (swap_flags & SWAP_FLAG_DISCARD_ONCE)
> +                               p->flags &= ~SWP_PAGE_DISCARD;
> +                       else if (swap_flags & SWAP_FLAG_DISCARD_PAGES)
> +                               p->flags &= ~SWP_AREA_DISCARD;

When using old swapon(8), this code turn off both flags, right?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
