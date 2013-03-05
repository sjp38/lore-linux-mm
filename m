Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 0E6366B0006
	for <linux-mm@kvack.org>; Tue,  5 Mar 2013 03:50:32 -0500 (EST)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RFC/PATCH 0/5] Contiguous Memory Allocator and get_user_pages()
Date: Tue, 5 Mar 2013 08:50:26 +0000
References: <1362466679-17111-1-git-send-email-m.szyprowski@samsung.com>
In-Reply-To: <1362466679-17111-1-git-send-email-m.szyprowski@samsung.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Message-Id: <201303050850.26615.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, linux-kernel@vger.kernel.org, Kyungmin Park <kyungmin.park@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>

On Tuesday 05 March 2013, Marek Szyprowski wrote:
> To solving this issue requires preventing locking of the pages, which
> are placed in CMA regions, for a long time. Our idea is to migrate
> anonymous page content before locking the page in get_user_pages(). This
> cannot be done automatically, as get_user_pages() interface is used very
> often for various operations, which usually last for a short period of
> time (like for example exec syscall). We have added a new flag
> indicating that the given get_user_space() call will grab pages for a
> long time, thus it is suitable to use the migration workaround in such
> cases.

Can you explain the tradeoff here? I would have expected that the default
should be to migrate pages out, and annotate the instances that we know
are performance critical and short-lived. That would at least appear
more reliable to me.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
