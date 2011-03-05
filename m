Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 56A5E8D003F
	for <linux-mm@kvack.org>; Sat,  5 Mar 2011 12:11:28 -0500 (EST)
Received: by gxk2 with SMTP id 2so1482217gxk.14
        for <linux-mm@kvack.org>; Sat, 05 Mar 2011 09:11:26 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1299343345-3984-8-git-send-email-cesarb@cesarb.net>
References: <1299343345-3984-1-git-send-email-cesarb@cesarb.net>
	<1299343345-3984-8-git-send-email-cesarb@cesarb.net>
Date: Sat, 5 Mar 2011 19:11:26 +0200
Message-ID: <AANLkTi=cP38uTMx922enrzz_q9-Zy3Vp8_uiQx47dzDS@mail.gmail.com>
Subject: Re: [PATCHv2 07/24] sys_swapon: remove initial value of name variable
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cesar Eduardo Barros <cesarb@cesarb.net>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Jens Axboe <jaxboe@fusionio.com>, linux-kernel@vger.kernel.org, Eric B Munson <emunson@mgebm.net>

On Sat, Mar 5, 2011 at 6:42 PM, Cesar Eduardo Barros <cesarb@cesarb.net> wrote:
> Now there is nothing which jumps to the cleanup blocks before the name
> variable is set. There is no need to set it initially to NULL anymore.
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
