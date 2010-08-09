Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id CA83E6B02D3
	for <linux-mm@kvack.org>; Mon,  9 Aug 2010 14:59:32 -0400 (EDT)
Received: by gxk4 with SMTP id 4so4627886gxk.14
        for <linux-mm@kvack.org>; Mon, 09 Aug 2010 11:59:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1281374816-904-6-git-send-email-ngupta@vflare.org>
References: <1281374816-904-1-git-send-email-ngupta@vflare.org>
	<1281374816-904-6-git-send-email-ngupta@vflare.org>
Date: Mon, 9 Aug 2010 21:59:30 +0300
Message-ID: <AANLkTikERp9DOpK=1R_UdjuNrS6dbAkX+Q5kysgVcv0k@mail.gmail.com>
Subject: Re: [PATCH 05/10] Reduce per table entry overhead by 4 bytes
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Nitin Gupta <ngupta@vflare.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <greg@kroah.com>, Linux Driver Project <devel@linuxdriverproject.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, Aug 9, 2010 at 8:26 PM, Nitin Gupta <ngupta@vflare.org> wrote:
> Each zram device maintains an array (table) that maps
> index within the device to the location of corresponding
> compressed chunk. Currently we store 'struct page' pointer,
> offset with page and various flags separately which takes
> 12 bytes per table entry. Now all these are encoded in a
> single 'phys_add_t' value which results in savings of 4 bytes
> per entry (except on PAE systems).
>
> Unfortunately, cleanups related to some variable renames
> were mixed in this patch. So, please bear some additional
> noise.

The noise makes this patch pretty difficult to review properly. Care
to spilt the patch into two pieces?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
