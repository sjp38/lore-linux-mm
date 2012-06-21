Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 947E26B00C9
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 08:42:40 -0400 (EDT)
Date: Thu, 21 Jun 2012 13:42:35 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [patch 3.5-rc3] mm, mempolicy: fix mbind() to do synchronous
 migration
Message-ID: <20120621124235.GN4011@suse.de>
References: <alpine.DEB.2.00.1206201758500.3068@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1206201758500.3068@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Jun 20, 2012 at 06:00:12PM -0700, David Rientjes wrote:
> If the range passed to mbind() is not allocated on nodes set in the
> nodemask, it migrates the pages to respect the constraint.
> 
> The final formal of migrate_pages() is a mode of type enum migrate_mode,
> not a boolean.  do_mbind() is currently passing "true" which is the
> equivalent of MIGRATE_SYNC_LIGHT.  This should instead be MIGRATE_SYNC
> for synchronous page migration.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
