Date: Sun, 8 Jun 2008 22:58:00 -0400
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH -mm 13/25] Noreclaim LRU Infrastructure
Message-ID: <20080608225800.17d2e29b@bree.surriel.com>
In-Reply-To: <20080608165434.67c87e5c.akpm@linux-foundation.org>
References: <20080606202838.390050172@redhat.com>
	<20080606202859.291472052@redhat.com>
	<20080606180506.081f686a.akpm@linux-foundation.org>
	<20080608163413.08d46427@bree.surriel.com>
	<20080608135704.a4b0dbe1.akpm@linux-foundation.org>
	<20080608173244.0ac4ad9b@bree.surriel.com>
	<20080608162208.a2683a6c.akpm@linux-foundation.org>
	<20080608193420.2a9cc030@bree.surriel.com>
	<20080608165434.67c87e5c.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, lee.schermerhorn@hp.com, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Sun, 8 Jun 2008 16:54:34 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> ho hum.  Can you remind us what problems this patchset actually
> addresses?  Preferably in order of seriousness?

Here are some other problems that my patch series can easily fix,
because file cache and anon/swap backed pages live on separate
LRUs:

http://feedblog.org/2007/09/29/using-o_direct-on-linux-and-innodb-to-fix-swap-insanity/

http://blogs.smugmug.com/don/2008/05/01/mysql-and-the-linux-swap-problem/

I do not know for sure whether the patch set does fix it yet for
everyone, or whether it needs some more tuning first, but it is
fairly easily fixable by tweaking the relative pressure on both
sets of LRU lists.

No tricks of skipping over one type of pages while scanning, or
treating the referenced bits differently when the moon is in some
particular phase required - one set of lists for each type of
pages, and variable pressure between the two.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
