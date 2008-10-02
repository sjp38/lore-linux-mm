Date: Thu, 2 Oct 2008 16:05:44 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/4] pull out zone cpuset and watermark checks for reuse
Message-Id: <20081002160544.16570d27.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1222864261-22570-3-git-send-email-apw@shadowen.org>
References: <1222864261-22570-1-git-send-email-apw@shadowen.org>
	<1222864261-22570-3-git-send-email-apw@shadowen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Peter Zijlstra <peterz@infradead.org>, Christoph Lameter <cl@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed,  1 Oct 2008 13:30:59 +0100
Andy Whitcroft <apw@shadowen.org> wrote:

> When allocating we need to confirm that the zone we are about to allocate
> from is acceptable to the CPUSET we are in, and that it does not violate
> the zone watermarks.  Pull these checks out so we can reuse them in a
> later patch.
> 
> Signed-off-by: Andy Whitcroft <apw@shadowen.org>
> Acked-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Reviewed-by: Rik van Riel <riel@redhat.com>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
