Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 9D4C96B0068
	for <linux-mm@kvack.org>; Sat, 17 Nov 2012 16:54:55 -0500 (EST)
Date: Sat, 17 Nov 2012 19:54:35 -0200
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH v12 4/7] mm: introduce compaction and migration for
 ballooned pages
Message-ID: <20121117215434.GA23879@x61.redhat.com>
References: <cover.1352656285.git.aquini@redhat.com>
 <6602296b38c073a5c6faa13ddbc74ceb1eceb2dd.1352656285.git.aquini@redhat.com>
 <50A7D0FA.2080709@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50A7D0FA.2080709@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, "Michael S. Tsirkin" <mst@redhat.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Rusty Russell <rusty@rustcorp.com.au>

On Sat, Nov 17, 2012 at 01:01:30PM -0500, Sasha Levin wrote:
> 
> I'm getting the following while fuzzing using trinity inside a KVM tools guest,
> on latest -next:
> 
> [ 1642.783728] BUG: unable to handle kernel NULL pointer dereference at 0000000000000194
> [ 1642.785083] IP: [<ffffffff8122b354>] isolate_migratepages_range+0x344/0x7b0
> 
> My guess is that we see those because of a race during the check in
> isolate_migratepages_range().
> 
> 
> Thanks,
> Sasha

Sasha, could you share your .config and steps you did used with trinity? So I
can attempt to reproduce this issue you reported.

Thanks, 
Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
