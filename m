Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 1DF786B0062
	for <linux-mm@kvack.org>; Mon, 16 Jul 2012 13:26:44 -0400 (EDT)
Date: Mon, 16 Jul 2012 12:26:41 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 2/3] mm: fix possible incorrect return value of
 migrate_pages() syscall
In-Reply-To: <1342455272-32703-2-git-send-email-js1304@gmail.com>
Message-ID: <alpine.DEB.2.00.1207161226000.32319@router.home>
References: <Yes> <1342455272-32703-1-git-send-email-js1304@gmail.com> <1342455272-32703-2-git-send-email-js1304@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sasha Levin <levinsasha928@gmail.com>

On Tue, 17 Jul 2012, Joonsoo Kim wrote

> do_migrate_pages() can return the number of pages not migrated.
> Because migrate_pages() syscall return this value directly,
> migrate_pages() syscall may return the number of pages not migrated.
> In fail case in migrate_pages() syscall, we should return error value.
> So change err to -EIO

Pages are not migrated because they are busy not because there is an
error. So lets return EBUSY.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
