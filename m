Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id D774D6B02D5
	for <linux-mm@kvack.org>; Mon,  9 Aug 2010 15:02:10 -0400 (EDT)
Received: by yxs7 with SMTP id 7so4630182yxs.14
        for <linux-mm@kvack.org>; Mon, 09 Aug 2010 12:02:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1281374816-904-9-git-send-email-ngupta@vflare.org>
References: <1281374816-904-1-git-send-email-ngupta@vflare.org>
	<1281374816-904-9-git-send-email-ngupta@vflare.org>
Date: Mon, 9 Aug 2010 22:02:08 +0300
Message-ID: <AANLkTi=u8m9ETGFx1RMjs+taaXGqaJjh41K7HZBm=kXG@mail.gmail.com>
Subject: Re: [PATCH 08/10] Some cleanups
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Nitin Gupta <ngupta@vflare.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <greg@kroah.com>, Linux Driver Project <devel@linuxdriverproject.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, Aug 9, 2010 at 8:26 PM, Nitin Gupta <ngupta@vflare.org> wrote:
> =A0- xvmalloc: Remove unnecessary stat_{inc,dec} and increment
> =A0 pages_stored directly
> =A0- xvmalloc: Initialize pointers with NULL instead of 0
> =A0- zram: Remove verbose message when use sets insane disksize
> =A0- zram: Mark some messages as pr_debug
> =A0- zram: Refine some comments
>
> Signed-off-by: Nitin Gupta <ngupta@vflare.org>

Acked-by: Pekka Enberg <penberg@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
