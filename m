Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 969DC6B005A
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 01:32:38 -0500 (EST)
Message-ID: <1324449156.21735.7.camel@joe2Laptop>
Subject: Re: [PATCH] vmalloc: remove #ifdef in function body
From: Joe Perches <joe@perches.com>
Date: Tue, 20 Dec 2011 22:32:36 -0800
In-Reply-To: <op.v6ttagny3l0zgt@mpn-glaptop>
References: <1324444679-9247-1-git-send-email-minchan@kernel.org>
	 <1324445481.20505.7.camel@joe2Laptop>
	 <20111221054531.GB28505@barrios-laptop.redhat.com>
	 <1324447099.21340.6.camel@joe2Laptop> <op.v6ttagny3l0zgt@mpn-glaptop>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, 2011-12-21 at 07:21 +0100, Michal Nazarewicz wrote:
> it seems the community prefers
> having ifdefs outside of the function.

Some do, some don't.

http://comments.gmane.org/gmane.linux.network/214543

If it's not in coding style, I suggest
it should be changed if it doesn't
add some other useful value.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
