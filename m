Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id D88976B0044
	for <linux-mm@kvack.org>; Sun, 20 Dec 2009 13:40:36 -0500 (EST)
Date: Sun, 20 Dec 2009 19:39:43 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 28 of 28] memcg huge memory
Message-ID: <20091220183943.GA6429@random.random>
References: <patchbomb.1261076403@v2.random>
 <d9c8d2160feb7d82736b.1261076431@v2.random>
 <20091218103312.2f61bbfc.kamezawa.hiroyu@jp.fujitsu.com>
 <20091218160437.GP29790@random.random>
 <ed35473ab7bac5ea2c509e82220565a4.squirrel@webmail-b.css.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ed35473ab7bac5ea2c509e82220565a4.squirrel@webmail-b.css.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Sat, Dec 19, 2009 at 08:06:50AM +0900, KAMEZAWA Hiroyuki wrote:
> My intentsion was adding a patch for adding "pagesize" parameters
> to charge/uncharge function may be able to reduce size of changes.

There's no need for that as my patch shows and I doubt it makes a lot
of difference at runtime, but it's up to you, I'm neutral. I suggest
is that you send me a patch and I integrate and use your version
;). I'll take care of adapting huge_memory.c myself if you want to add
the size param to the outer call.

Now if I manage to finish this khugepaged I could do a new submit with
a new round of changes and cleanups and stats (latest polishing
especially thanks to Mel review).

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
