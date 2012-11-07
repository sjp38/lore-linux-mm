Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id CDC6B6B002B
	for <linux-mm@kvack.org>; Wed,  7 Nov 2012 14:56:12 -0500 (EST)
Date: Wed, 7 Nov 2012 11:56:10 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v11 1/7] mm: adjust
 address_space_operations.migratepage() return code
Message-Id: <20121107115610.c0cb650c.akpm@linux-foundation.org>
In-Reply-To: <74bc30697313206e1225f6fc658bc5952b588dcc.1352256085.git.aquini@redhat.com>
References: <cover.1352256081.git.aquini@redhat.com>
	<74bc30697313206e1225f6fc658bc5952b588dcc.1352256085.git.aquini@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>, Peter Zijlstra <peterz@infradead.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Wed,  7 Nov 2012 01:05:48 -0200
Rafael Aquini <aquini@redhat.com> wrote:

> This patch introduces MIGRATEPAGE_SUCCESS as the default return code
> for address_space_operations.migratepage() method and documents the
> expected return code for the same method in failure cases.

I hit a large number of rejects applying this against linux-next.  Due
to the increasingly irritating sched/numa code in there.

I attempted to fix it up and also converted some (but not all) of the
implicit tests of `rc' against zero.

Please check the result very carefully - more changes will be needed.

All those

-	if (rc)
+	if (rc != MIGRATEPAGE_SUCCESS)

changes are a pain.  Perhaps we shouldn't bother.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
