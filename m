Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 367B06B0011
	for <linux-mm@kvack.org>; Tue, 24 May 2011 18:32:07 -0400 (EDT)
Received: by qwa26 with SMTP id 26so5199957qwa.14
        for <linux-mm@kvack.org>; Tue, 24 May 2011 15:32:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110524133204.GA11529@nb-core2.darkstar.lan>
References: <20110524133204.GA11529@nb-core2.darkstar.lan>
Date: Wed, 25 May 2011 07:32:05 +0900
Message-ID: <BANLkTinu_kUij0gj3RswwWahLwvOKoXiLg@mail.gmail.com>
Subject: Re: [PATCH] Delete unused variable no_wb.
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luca Tettamanti <kronos.it@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Hellwig <hch@lst.de>, Andrew Morton <akpm@linux-foundation.org>

On Tue, May 24, 2011 at 10:32 PM, Luca Tettamanti <kronos.it@gmail.com> wrote:
> The number of writeback threads was removed from the output by c1955ce3.
>
> Signed-off-by: Luca Tettamanti <kronos.it@gmail.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

Good eye.
-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
