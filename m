Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 198C56B008C
	for <linux-mm@kvack.org>; Tue, 26 Jan 2010 11:01:09 -0500 (EST)
Date: Tue, 26 Jan 2010 10:00:46 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 03 of 31] alter compound get_page/put_page
In-Reply-To: <20100126153140.GK30452@random.random>
Message-ID: <alpine.DEB.2.00.1001261000380.23549@router.home>
References: <patchbomb.1264513915@v2.random> <936cd613e4ae2d20c62b.1264513918@v2.random> <4B5F037D.9050801@redhat.com> <20100126153140.GK30452@random.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, Christoph Hellwig <chellwig@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, 26 Jan 2010, Andrea Arcangeli wrote:

> On Tue, Jan 26, 2010 at 10:00:13AM -0500, Rik van Riel wrote:
> > Ahh, I see you added the #ifdef in this patch.
>
> Yep, or x86 wouldn't build because there wasn't enough space in
> page-flags. #7 should build on all archs including i386. I guess I
> should have folded the changes in the previous patch like said in
> previous email, I'll clean it up now, end result is the same.

Sounds good.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
