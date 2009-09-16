Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 5ACF16B004F
	for <linux-mm@kvack.org>; Tue, 15 Sep 2009 20:12:39 -0400 (EDT)
Received: by yxe6 with SMTP id 6so6035366yxe.22
        for <linux-mm@kvack.org>; Tue, 15 Sep 2009 17:12:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <Pine.LNX.4.64.0909152206220.28874@sister.anvils>
References: <Pine.LNX.4.64.0909152206220.28874@sister.anvils>
Date: Wed, 16 Sep 2009 09:12:42 +0900
Message-ID: <28c262360909151712k768d7e1s150899162e28daf4@mail.gmail.com>
Subject: Re: [PATCH] hwpoison: fix uninitialized warning
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Sep 16, 2009 at 6:19 AM, Hugh Dickins
<hugh.dickins@tiscali.co.uk> wrote:
> Fix mmotm build warning, presumably also in linux-next:
> mm/memory.c: In function `do_swap_page':
> mm/memory.c:2498: warning: `pte' may be used uninitialized in this function
>
> Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
