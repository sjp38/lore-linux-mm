Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id BAF216B004D
	for <linux-mm@kvack.org>; Fri, 27 Jul 2012 16:57:35 -0400 (EDT)
Date: Fri, 27 Jul 2012 15:57:33 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RESEND PATCH 2/4 v3] mm: fix possible incorrect return value
 of migrate_pages() syscall
In-Reply-To: <1343411703-2720-2-git-send-email-js1304@gmail.com>
Message-ID: <alpine.DEB.2.00.1207271554480.25434@router.home>
References: <Yes> <1343411703-2720-1-git-send-email-js1304@gmail.com> <1343411703-2720-2-git-send-email-js1304@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sasha Levin <levinsasha928@gmail.com>

On Sat, 28 Jul 2012, Joonsoo Kim wrote:

> do_migrate_pages() can return the number of pages not migrated.
> Because migrate_pages() syscall return this value directly,
> migrate_pages() syscall may return the number of pages not migrated.
> In fail case in migrate_pages() syscall, we should return error value.
> So change err to -EBUSY

Lets leave this alone. This would change the migrate_pages semantics
because a successful move of N out of M pages would be marked as a
total failure although pages were in fact moved.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
