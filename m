Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 25A688D003F
	for <linux-mm@kvack.org>; Sat,  5 Mar 2011 12:25:17 -0500 (EST)
Received: by gwj15 with SMTP id 15so1593843gwj.8
        for <linux-mm@kvack.org>; Sat, 05 Mar 2011 09:25:15 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1299343345-3984-19-git-send-email-cesarb@cesarb.net>
References: <1299343345-3984-1-git-send-email-cesarb@cesarb.net>
	<1299343345-3984-19-git-send-email-cesarb@cesarb.net>
Date: Sat, 5 Mar 2011 19:25:15 +0200
Message-ID: <AANLkTim50m5KDdmcWixL+4-nw2kWnddOgsUaXRbrBMvR@mail.gmail.com>
Subject: Re: [PATCHv2 18/24] sys_swapon: call swap_cgroup_swapon earlier
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cesar Eduardo Barros <cesarb@cesarb.net>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Jens Axboe <jaxboe@fusionio.com>, linux-kernel@vger.kernel.org, Eric B Munson <emunson@mgebm.net>

On Sat, Mar 5, 2011 at 6:42 PM, Cesar Eduardo Barros <cesarb@cesarb.net> wrote:
> The call to swap_cgroup_swapon is in the middle of loading the swap map
> and extents. As it only does memory allocation and does not depend on
> the swapfile layout (map/extents), it can be called earlier (or later).
>
> Move it to just after the allocation of swap_map, since it is
> conceptually similar (allocates a map).
>
> Signed-off-by: Cesar Eduardo Barros <cesarb@cesarb.net>
> Tested-by: Eric B Munson <emunson@mgebm.net>
> Acked-by: Eric B Munson <emunson@mgebm.net>

Reviewed-by: Pekka Enberg <penberg@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
