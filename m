Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 684EE8D003F
	for <linux-mm@kvack.org>; Sat,  5 Mar 2011 12:20:44 -0500 (EST)
Received: by gyb13 with SMTP id 13so1520283gyb.14
        for <linux-mm@kvack.org>; Sat, 05 Mar 2011 09:20:25 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1299343345-3984-25-git-send-email-cesarb@cesarb.net>
References: <1299343345-3984-1-git-send-email-cesarb@cesarb.net>
	<1299343345-3984-25-git-send-email-cesarb@cesarb.net>
Date: Sat, 5 Mar 2011 19:20:25 +0200
Message-ID: <AANLkTinEsm6yGcaTMZOVGShSvCVKKMQnHBQec6w1_MtS@mail.gmail.com>
Subject: Re: [PATCHv2 24/24] sys_swapon: separate final enabling of the swapfile
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cesar Eduardo Barros <cesarb@cesarb.net>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Jens Axboe <jaxboe@fusionio.com>, linux-kernel@vger.kernel.org, Eric B Munson <emunson@mgebm.net>

On Sat, Mar 5, 2011 at 6:42 PM, Cesar Eduardo Barros <cesarb@cesarb.net> wrote:
> The block in sys_swapon which does the final adjustments to the
> swap_info_struct and to swap_list is the same as the block which
> re-inserts it again at sys_swapoff on failure of try_to_unuse(). Move
> this code to a separate function, and use it both in sys_swapon and
> sys_swapoff.
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
