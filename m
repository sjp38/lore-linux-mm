Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 5AE4C6B0031
	for <linux-mm@kvack.org>; Thu,  8 Aug 2013 15:54:09 -0400 (EDT)
Received: by mail-oa0-f42.google.com with SMTP id i18so6022350oag.15
        for <linux-mm@kvack.org>; Thu, 08 Aug 2013 12:54:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1375980460-28311-1-git-send-email-toshi.kani@hp.com>
References: <1375980460-28311-1-git-send-email-toshi.kani@hp.com>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Thu, 8 Aug 2013 15:53:48 -0400
Message-ID: <CAHGf_=qPnmpqxeQ1TkXxapRFvdLbLhC53qS3kNATurhoxKd2PQ@mail.gmail.com>
Subject: Re: [PATCH] mm/hotplug: Verify hotplug memory range
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, dave@sr71.net, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, "vasilis.liaskovitis" <vasilis.liaskovitis@profitbricks.com>

On Thu, Aug 8, 2013 at 12:47 PM, Toshi Kani <toshi.kani@hp.com> wrote:
> add_memory() and remove_memory() can only handle a memory range aligned
> with section.  There are problems when an unaligned range is added and
> then deleted as follows:
>
>  - add_memory() with an unaligned range succeeds, but __add_pages()
>    called from add_memory() adds a whole section of pages even though
>    a given memory range is less than the section size.
>  - remove_memory() to the added unaligned range hits BUG_ON() in
>    __remove_pages().
>
> This patch changes add_memory() and remove_memory() to check if a given
> memory range is aligned with section at the beginning.  As the result,
> add_memory() fails with -EINVAL when a given range is unaligned, and
> does not add such memory range.  This prevents remove_memory() to be
> called with an unaligned range as well.  Note that remove_memory() has
> to use BUG_ON() since this function cannot fail.
>
> Signed-off-by: Toshi Kani <toshi.kani@hp.com>
> ---
>  mm/memory_hotplug.c |   22 ++++++++++++++++++++++

memory_hotplug.c is maintained by me and kamezawa-san. Please cc us
if you have a subsequent patch.

Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
