Date: Sat, 7 Jul 2007 07:31:57 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memory unplug v7 [4/6] - page isolation
Message-Id: <20070707073157.122d4d55.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070706152828.9ae57453.akpm@linux-foundation.org>
References: <20070706181903.428c3713.kamezawa.hiroyu@jp.fujitsu.com>
	<20070706182611.b16b6720.kamezawa.hiroyu@jp.fujitsu.com>
	<20070706152828.9ae57453.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, clameter@sgi.com, mel@csn.ul.ie
List-ID: <linux-mm.kvack.org>

On Fri, 6 Jul 2007 15:28:28 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Fri, 6 Jul 2007 18:26:11 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > +/*
> > + * start_isolate_page_range() -- make page-allocation-type of range of pages
> > + * to be MIGRATE_ISOLATE.
> 
> I think kerneldoc requires that the above all be on a single line.
> 
Hmm...I'll read it again and fix this.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
