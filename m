Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 2FCAB6B01E3
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 04:27:25 -0400 (EDT)
Received: by gyg4 with SMTP id 4so3362486gyg.14
        for <linux-mm@kvack.org>; Tue, 13 Apr 2010 01:27:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1270522777-9216-1-git-send-email-lliubbo@gmail.com>
References: <1270522777-9216-1-git-send-email-lliubbo@gmail.com>
Date: Tue, 13 Apr 2010 17:27:22 +0900
Message-ID: <i2j28c262361004130127g8725d702jd2b6714c9944527c@mail.gmail.com>
Subject: Re: [PATCH] mempolicy:add GFP_THISNODE when allocing new page
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: Bob Liu <lliubbo@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, andi@firstfloor.org, rientjes@google.com, lee.schermerhorn@hp.com
List-ID: <linux-mm.kvack.org>

On Tue, Apr 6, 2010 at 11:59 AM, Bob Liu <lliubbo@gmail.com> wrote:
> In funtion migrate_pages(), if the dest node have no
> enough free pages,it will fallback to other nodes.
> Add GFP_THISNODE to avoid this, the same as what
> funtion new_page_node() do in migrate.c.
>
> Signed-off-by: Bob Liu <lliubbo@gmail.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

Thanks, Bob.


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
