Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 071896B004D
	for <linux-mm@kvack.org>; Tue, 31 Jul 2012 10:04:47 -0400 (EDT)
Date: Tue, 31 Jul 2012 09:04:44 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RESEND PATCH 4/4 v3] mm: fix possible incorrect return value
 of move_pages() syscall
In-Reply-To: <CAAmzW4P6rqywK89q71DXzumREsJNGq0O4RrfdiHP2thrRSy9Gg@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1207310903290.32295@router.home>
References: <1343411703-2720-1-git-send-email-js1304@gmail.com> <1343411703-2720-4-git-send-email-js1304@gmail.com> <alpine.DEB.2.00.1207271550190.25434@router.home> <CAAmzW4MdiJOaZW_b+fz1uYyj0asTCveN=24st4xKymKEvkzdgQ@mail.gmail.com>
 <alpine.DEB.2.00.1207301425410.28838@router.home> <CAAmzW4P6rqywK89q71DXzumREsJNGq0O4RrfdiHP2thrRSy9Gg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: JoonSoo Kim <js1304@gmail.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Brice Goglin <brice@myri.com>, Minchan Kim <minchan@kernel.org>, Michael Kerrisk <mtk.manpages@gmail.com>

On Tue, 31 Jul 2012, JoonSoo Kim wrote:

> In man page, there is following statement.
> "status is an array of integers that return the status of each page.  The array
> only contains valid values if move_pages() did not return an error."

> And current implementation of move_pages() syscall doesn't return the number
> of pages not moved, just return 0 when it encounter some failed pages.
> So, if u want to fix the man page, u should fix do_pages_move() first.

Hmm... Yeah actually that is sufficient since the status is readily
obtainable from the status array. It would be better though if the
function would return the number of pages not moved in the same way as
migrate_pages().



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
