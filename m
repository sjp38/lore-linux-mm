Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id A327D6B0275
	for <linux-mm@kvack.org>; Sun,  7 Jan 2018 20:58:24 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id d199so3075316pfd.9
        for <linux-mm@kvack.org>; Sun, 07 Jan 2018 17:58:24 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id ay12sor3878032plb.110.2018.01.07.17.58.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 07 Jan 2018 17:58:23 -0800 (PST)
Date: Mon, 8 Jan 2018 10:58:18 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] mm: ratelimit end_swap_bio_write() error
Message-ID: <20180108015818.GA533@jagdpanzerIV>
References: <20180106043407.25193-1-sergey.senozhatsky@gmail.com>
 <20180106094124.GB16576@dhcp22.suse.cz>
 <20180106100313.GA527@tigerII.localdomain>
 <20180106133417.GA23629@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180106133417.GA23629@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On (01/06/18 14:34), Michal Hocko wrote:
> > zsmalloc allocation is just one possibility; an error in
> > compressing algorithm is another one, yet is rather unlikely.
> > most likely it's OOM which can cause problems. but in any case
> > it's sort of unclear what should be done. an error can be a
> > temporary one or a fatal one, just like in __swap_writepage()
> > case. so may be both write error printk()-s can be dropped.
> 
> Then I would suggest starting with sorting out which of those errors are
> critical and which are not and report the error accordingly. I am sorry
> to be fuzzy here but I am not familiar with the code to be more
> specific. Anyway ratelimiting sounds more like a paper over than a real
> solution. Also it sounds quite scary that you can see so many failures
> to actually lock up the system just by printing a message...

the lockup is not the main problem and I'm not really trying to
address it here. we simply can fill up the entire kernel logbuf
with the same "Write-error on swap-device" errors.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
