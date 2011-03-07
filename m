Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 094B98D0039
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 04:23:01 -0500 (EST)
Received: by gxk2 with SMTP id 2so2034802gxk.14
        for <linux-mm@kvack.org>; Mon, 07 Mar 2011 01:23:00 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1299343345-3984-16-git-send-email-cesarb@cesarb.net>
References: <1299343345-3984-1-git-send-email-cesarb@cesarb.net>
	<1299343345-3984-16-git-send-email-cesarb@cesarb.net>
Date: Mon, 7 Mar 2011 11:23:00 +0200
Message-ID: <AANLkTinZtF2Gw4Ji4ZkTjgkLA45sQMH23HGPw7pKJKrD@mail.gmail.com>
Subject: Re: [PATCHv2 15/24] sys_swapon: move setting of swapfilepages near use
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cesar Eduardo Barros <cesarb@cesarb.net>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Jens Axboe <jaxboe@fusionio.com>, linux-kernel@vger.kernel.org, Eric B Munson <emunson@mgebm.net>

On Sat, Mar 5, 2011 at 6:42 PM, Cesar Eduardo Barros <cesarb@cesarb.net> wrote:
> There is no reason I can see to read inode->i_size long before it is
> needed. Move its read to just before it is needed, to reduce the
> variable lifetime.
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
