Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 45DC78D003F
	for <linux-mm@kvack.org>; Sat,  5 Mar 2011 12:21:41 -0500 (EST)
Received: by yib2 with SMTP id 2so1471228yib.14
        for <linux-mm@kvack.org>; Sat, 05 Mar 2011 09:21:39 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1299343345-3984-24-git-send-email-cesarb@cesarb.net>
References: <1299343345-3984-1-git-send-email-cesarb@cesarb.net>
	<1299343345-3984-24-git-send-email-cesarb@cesarb.net>
Date: Sat, 5 Mar 2011 19:21:39 +0200
Message-ID: <AANLkTinqaotJoaGZh=5iO639JEX7-b03U0LUjrKBTzBo@mail.gmail.com>
Subject: Re: [PATCHv2 23/24] sys_swapoff: change order to match sys_swapon
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cesar Eduardo Barros <cesarb@cesarb.net>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Jens Axboe <jaxboe@fusionio.com>, linux-kernel@vger.kernel.org, Eric B Munson <emunson@mgebm.net>

On Sat, Mar 5, 2011 at 6:42 PM, Cesar Eduardo Barros <cesarb@cesarb.net> wrote:
> The block in sys_swapon which does the final adjustments to the
> swap_info_struct and to swap_list is the same as the block which
> re-inserts it again at sys_swapoff on failure of try_to_unuse(), except
> for the order of the operations within the lock. Since the order should
> not matter, arbitrarily change sys_swapoff to match sys_swapon, in
> preparation to making both share the same code.
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
