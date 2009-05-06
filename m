Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id B3B2F6B003D
	for <linux-mm@kvack.org>; Wed,  6 May 2009 03:03:27 -0400 (EDT)
Received: by qyk29 with SMTP id 29so10600062qyk.12
        for <linux-mm@kvack.org>; Wed, 06 May 2009 00:03:27 -0700 (PDT)
Date: Wed, 6 May 2009 11:03:23 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH -mmotm] mm: setup_per_zone_inactive_ratio - fix comment
	and make it __init
Message-ID: <20090506070323.GC4865@lenovo>
References: <20090506061923.GA4865@lenovo> <20090506155145.e657b271.minchan.kim@barrios-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090506155145.e657b271.minchan.kim@barrios-desktop>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, LMMML <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

[Minchan Kim - Wed, May 06, 2009 at 03:51:45PM +0900]
| On Wed, 6 May 2009 10:19:23 +0400
| Cyrill Gorcunov <gorcunov@openvz.org> wrote:
| 
| > The caller of setup_per_zone_inactive_ratio is module_init function.
| 
| __init :)
| 
| > No need to keep the callee after is completed as well.
| > Also fix a comment.
| > 
| > CC: David Rientjes <rientjes@google.com>
| > Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
| 
| Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
| I guess the comment was a typo. 

Thanks Minchan. Actually it's not a typo :)
module_init function is supposed to be __initcall
function anyway. But it's confusing I could fix
changelog.

	-- Cyrill

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
