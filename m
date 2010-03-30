Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 981416B022E
	for <linux-mm@kvack.org>; Mon, 29 Mar 2010 20:03:06 -0400 (EDT)
Received: by pwi2 with SMTP id 2so3623928pwi.14
        for <linux-mm@kvack.org>; Mon, 29 Mar 2010 17:03:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1269874629-1736-1-git-send-email-lliubbo@gmail.com>
References: <1269874629-1736-1-git-send-email-lliubbo@gmail.com>
Date: Tue, 30 Mar 2010 09:03:04 +0900
Message-ID: <28c262361003291703i5382e342q773ffb16e3324cf5@mail.gmail.com>
Subject: Re: [RFC][PATCH] migrate_pages:skip migration between intersect nodes
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: Bob Liu <lliubbo@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, cl@linux-foundation.org, lee.schermerhorn@hp.com, andi@firstfloor.org, minchar.kim@gmail.com
List-ID: <linux-mm.kvack.org>

Hi, Bob

On Mon, Mar 29, 2010 at 11:57 PM, Bob Liu <lliubbo@gmail.com> wrote:
> In current do_migrate_pages(),if from_nodes and to_nodes have some
> intersect nodes,pages in these intersect nodes will also be
> migrated.
> eg. Assume that, from_nodes: 1,2,3,4 to_nodes: 2,3,4,5. Then these
> migrates will happen:
> migrate_pages(4,5);
> migrate_pages(3,4);
> migrate_pages(2,3);
> migrate_pages(1,2);
>
> But the user just want all pages in from_nodes move to to_nodes,
> only migrate(1,2)(ignore the intersect nodes.) can satisfied
> the user's request.
>
> I amn't sure what's migrate_page's semantic.
> Hoping for your suggestions.

I didn't see 8:migratepages Lee pointed at that time.
The description matches current migrate_pages's behavior exactly.

I agree Lee's opinion.
Let's wait Christoph's reply what is semantic
and why it doesn't have man page.


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
