Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id D47678D0040
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 09:43:27 -0400 (EDT)
Date: Tue, 22 Mar 2011 08:43:23 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm: remove unused zone_idx variable from
 set_migratetype_isolate
In-Reply-To: <20110322112647.GA5086@swordfish.minsk.epam.com>
Message-ID: <alpine.DEB.2.00.1103220843040.14318@router.home>
References: <20110322112647.GA5086@swordfish.minsk.epam.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


On Tue, 22 Mar 2011, Sergey Senozhatsky wrote:

> mm: remove unused variable zone_idx and zone_idx call from set_migratetype_isolate
>
> Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Reviewed-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
