Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 898076B0038
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 20:00:21 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id j26so15393734pff.8
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 17:00:21 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id p5sor4302569pga.4.2017.12.19.17.00.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Dec 2017 17:00:20 -0800 (PST)
Date: Wed, 20 Dec 2017 10:00:15 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v2] mm/zsmalloc: simplify shrinker init/destroy
Message-ID: <20171220010015.GA21976@jagdpanzerIV>
References: <20171219102213.GA435@jagdpanzerIV>
 <1513680552-9798-1-git-send-email-akaraliou.dev@gmail.com>
 <20171219151341.GC15210@dhcp22.suse.cz>
 <20171219152536.GA591@tigerII.localdomain>
 <20171219155815.GC2787@dhcp22.suse.cz>
 <15c19718-c08e-e7f6-8af9-9651db1b11cc@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <15c19718-c08e-e7f6-8af9-9651db1b11cc@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aliaksei Karaliou <akaraliou.dev@gmail.com>
Cc: Michal Hocko <mhocko@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On (12/19/17 20:45), Aliaksei Karaliou wrote:
[..]
> > OK, it smells like an abuse of the API but please add a comment
> > clarifying that.
> > 
> > Thanks!
> I can update the existing comment to be like that:
>         /*
>          * Not critical since shrinker is only used to trigger internal
>          * de-fragmentation of the pool which is pretty optional thing.
>          * If registration fails we still can use the pool normally and
>          * user can trigger compaction manually. Thus, ignore return code.
>          */
> 
> Sergey, does this sound well to you ? Or not clear enough, Michal ?

looks good. thanks!

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
