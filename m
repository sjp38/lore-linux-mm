Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id D1E4B8D0039
	for <linux-mm@kvack.org>; Sat,  5 Mar 2011 12:07:12 -0500 (EST)
Received: by yib2 with SMTP id 2so1467167yib.14
        for <linux-mm@kvack.org>; Sat, 05 Mar 2011 09:07:11 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1299343345-3984-4-git-send-email-cesarb@cesarb.net>
References: <1299343345-3984-1-git-send-email-cesarb@cesarb.net>
	<1299343345-3984-4-git-send-email-cesarb@cesarb.net>
Date: Sat, 5 Mar 2011 19:07:11 +0200
Message-ID: <AANLkTin3EWz4g_y03M7TOzAmD+wYJkR3a-cOJOy4ru07@mail.gmail.com>
Subject: Re: [PATCHv2 03/24] sys_swapon: do not depend on "type" after allocation
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cesar Eduardo Barros <cesarb@cesarb.net>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Jens Axboe <jaxboe@fusionio.com>, linux-kernel@vger.kernel.org, Eric B Munson <emunson@mgebm.net>

On Sat, Mar 5, 2011 at 6:42 PM, Cesar Eduardo Barros <cesarb@cesarb.net> wrote:
> Within sys_swapon, after the swap_info entry has been allocated, we
> always have type == p->type and swap_info[type] == p. Use this fact to
> reduce the dependency on the "type" local variable within the function,
> as a preparation to move the allocation of the swap_info entry to a
> separate function.
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
