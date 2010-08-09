Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 1ED616B02CE
	for <linux-mm@kvack.org>; Mon,  9 Aug 2010 14:44:41 -0400 (EDT)
Received: by pvc30 with SMTP id 30so1053863pvc.14
        for <linux-mm@kvack.org>; Mon, 09 Aug 2010 11:44:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1281374816-904-4-git-send-email-ngupta@vflare.org>
References: <1281374816-904-1-git-send-email-ngupta@vflare.org>
	<1281374816-904-4-git-send-email-ngupta@vflare.org>
Date: Mon, 9 Aug 2010 21:44:39 +0300
Message-ID: <AANLkTimC=YGQKDmjsYir7iUwc9AtfkmJrcrrNptk0wZz@mail.gmail.com>
Subject: Re: [PATCH 03/10] Use percpu stats
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Nitin Gupta <ngupta@vflare.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <greg@kroah.com>, Linux Driver Project <devel@linuxdriverproject.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, Aug 9, 2010 at 8:26 PM, Nitin Gupta <ngupta@vflare.org> wrote:
> Also remove references to removed stats (ex: good_comress).
>
> Signed-off-by: Nitin Gupta <ngupta@vflare.org>

Acked-by: Pekka Enberg <penberg@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
