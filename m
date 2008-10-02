Date: Thu, 2 Oct 2008 16:05:12 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/4] pull out the page pre-release and sanity check
 logic for reuse
Message-Id: <20081002160512.b87c3440.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1222864261-22570-2-git-send-email-apw@shadowen.org>
References: <1222864261-22570-1-git-send-email-apw@shadowen.org>
	<1222864261-22570-2-git-send-email-apw@shadowen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Peter Zijlstra <peterz@infradead.org>, Christoph Lameter <cl@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed,  1 Oct 2008 13:30:58 +0100
Andy Whitcroft <apw@shadowen.org> wrote:

> When we are about to release a page we perform a number of actions
> on that page.  We clear down any anonymous mappings, confirm that
> the page is safe to release, check for freeing locks, before mapping
> the page should that be required.  Pull this processing out into a
> helper function for reuse in a later patch.
> 
> Note that we do not convert the similar cleardown in free_hot_cold_page()
> as the optimiser is unable to squash the loops during the inline.
> 
> Signed-off-by: Andy Whitcroft <apw@shadowen.org>
> Acked-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Reviewed-by: Rik van Riel <riel@redhat.com>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiruyo@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
