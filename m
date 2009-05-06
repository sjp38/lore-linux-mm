Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 9CA976B003D
	for <linux-mm@kvack.org>; Wed,  6 May 2009 03:12:22 -0400 (EDT)
Received: by yx-out-1718.google.com with SMTP id 36so2751977yxh.26
        for <linux-mm@kvack.org>; Wed, 06 May 2009 00:12:33 -0700 (PDT)
Date: Wed, 6 May 2009 11:12:28 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH -mmotm] mm: setup_per_zone_inactive_ratio - fix comment
	and make it __init
Message-ID: <20090506071228.GD4865@lenovo>
References: <20090506061923.GA4865@lenovo> <20090506155145.e657b271.minchan.kim@barrios-desktop> <20090506070323.GC4865@lenovo>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090506070323.GC4865@lenovo>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, LMMML <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

[Cyrill Gorcunov - Wed, May 06, 2009 at 11:03:23AM +0400]
... 
| Thanks Minchan. Actually it's not a typo :)
| module_init function is supposed to be __initcall
| function anyway. But it's confusing I could fix
| changelog.
| 
| 	-- Cyrill

Andrew, could you s/module_init/__init/ in changelog
please?

	-- Cyrill

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
