Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 3EE106B004D
	for <linux-mm@kvack.org>; Sat, 28 Jul 2012 02:16:29 -0400 (EDT)
Received: by obhx4 with SMTP id x4so6742719obh.14
        for <linux-mm@kvack.org>; Fri, 27 Jul 2012 23:16:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1207271554480.25434@router.home>
References: <1343411703-2720-1-git-send-email-js1304@gmail.com>
	<1343411703-2720-2-git-send-email-js1304@gmail.com>
	<alpine.DEB.2.00.1207271554480.25434@router.home>
Date: Sat, 28 Jul 2012 15:16:28 +0900
Message-ID: <CAAmzW4O04LZim-DZQ5JYEEpBL89Tts_OjRqbRKB2AAdE17O7HQ@mail.gmail.com>
Subject: Re: [RESEND PATCH 2/4 v3] mm: fix possible incorrect return value of
 migrate_pages() syscall
From: JoonSoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sasha Levin <levinsasha928@gmail.com>

2012/7/28 Christoph Lameter <cl@linux.com>:
> On Sat, 28 Jul 2012, Joonsoo Kim wrote:
>
>> do_migrate_pages() can return the number of pages not migrated.
>> Because migrate_pages() syscall return this value directly,
>> migrate_pages() syscall may return the number of pages not migrated.
>> In fail case in migrate_pages() syscall, we should return error value.
>> So change err to -EBUSY
>
> Lets leave this alone. This would change the migrate_pages semantics
> because a successful move of N out of M pages would be marked as a
> total failure although pages were in fact moved.
>

Okay.
Then, do we need to fix man-page of migrate_pages() syscall?
According to man-page, only returning 0 or -1 is valid.
Without this patch, it can return positive value.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
