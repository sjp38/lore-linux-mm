Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8348A6B00C4
	for <linux-mm@kvack.org>; Tue, 13 Oct 2009 15:01:08 -0400 (EDT)
Date: Tue, 13 Oct 2009 11:59:57 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/3] mm: move inc_zone_page_state(NR_ISOLATED) to just
 isolated place
Message-Id: <20091013115957.e2871557.akpm@linux-foundation.org>
In-Reply-To: <20091009100527.1284.A69D9226@jp.fujitsu.com>
References: <20091009100527.1284.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

On Fri,  9 Oct 2009 10:06:58 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> This patch series is trivial cleanup and fix of page migration.
> 
> 
> ==========================================================
> 
> Christoph pointed out inc_zone_page_state(NR_ISOLATED) should be placed
> in right after isolate_page().

The bugfixes are appropriate for 2.6.32 and should be backported into
-stable too, I think.  I haven't checked to see how long those bugs
have been present.

The cleanup is more appropriate for 2.6.33 so I had to switch the order
of these patches.  Hopefully the bugfixes were not dependent on the
cleanup.  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
