Date: Fri, 6 Jul 2007 15:28:28 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] memory unplug v7 [4/6] - page isolation
Message-Id: <20070706152828.9ae57453.akpm@linux-foundation.org>
In-Reply-To: <20070706182611.b16b6720.kamezawa.hiroyu@jp.fujitsu.com>
References: <20070706181903.428c3713.kamezawa.hiroyu@jp.fujitsu.com>
	<20070706182611.b16b6720.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Christoph Lameter <clameter@sgi.com>, mel@csn.ul.ie
List-ID: <linux-mm.kvack.org>

On Fri, 6 Jul 2007 18:26:11 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> +/*
> + * start_isolate_page_range() -- make page-allocation-type of range of pages
> + * to be MIGRATE_ISOLATE.

I think kerneldoc requires that the above all be on a single line.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
