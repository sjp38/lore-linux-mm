Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 4A97E6B004D
	for <linux-mm@kvack.org>; Mon, 30 Jul 2012 15:30:38 -0400 (EDT)
Date: Mon, 30 Jul 2012 14:30:35 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RESEND PATCH 2/4 v3] mm: fix possible incorrect return value
 of migrate_pages() syscall
In-Reply-To: <CAAmzW4O04LZim-DZQ5JYEEpBL89Tts_OjRqbRKB2AAdE17O7HQ@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1207301429500.28838@router.home>
References: <1343411703-2720-1-git-send-email-js1304@gmail.com> <1343411703-2720-2-git-send-email-js1304@gmail.com> <alpine.DEB.2.00.1207271554480.25434@router.home> <CAAmzW4O04LZim-DZQ5JYEEpBL89Tts_OjRqbRKB2AAdE17O7HQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: JoonSoo Kim <js1304@gmail.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sasha Levin <levinsasha928@gmail.com>, Michael Kerrisk <mtk.manpages@gmail.com>

On Sat, 28 Jul 2012, JoonSoo Kim wrote:

> 2012/7/28 Christoph Lameter <cl@linux.com>:
> > On Sat, 28 Jul 2012, Joonsoo Kim wrote:
> >
> >> do_migrate_pages() can return the number of pages not migrated.
> >> Because migrate_pages() syscall return this value directly,
> >> migrate_pages() syscall may return the number of pages not migrated.
> >> In fail case in migrate_pages() syscall, we should return error value.
> >> So change err to -EBUSY
> >
> > Lets leave this alone. This would change the migrate_pages semantics
> > because a successful move of N out of M pages would be marked as a
> > total failure although pages were in fact moved.
> >
>
> Okay.
> Then, do we need to fix man-page of migrate_pages() syscall?
> According to man-page, only returning 0 or -1 is valid.
> Without this patch, it can return positive value.

Yes the manpage needs updating to say that it can return the number of
pages not migrated.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
