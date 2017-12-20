Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id D6FBE6B0038
	for <linux-mm@kvack.org>; Wed, 20 Dec 2017 03:29:33 -0500 (EST)
Received: by mail-lf0-f70.google.com with SMTP id z130so4970151lff.18
        for <linux-mm@kvack.org>; Wed, 20 Dec 2017 00:29:33 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t75sor2264893lfe.64.2017.12.20.00.29.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Dec 2017 00:29:32 -0800 (PST)
Subject: Re: [PATCH v2] mm/zsmalloc: simplify shrinker init/destroy
References: <20171219102213.GA435@jagdpanzerIV>
 <1513680552-9798-1-git-send-email-akaraliou.dev@gmail.com>
 <20171219151341.GC15210@dhcp22.suse.cz>
 <20171219152536.GA591@tigerII.localdomain>
 <20171219155815.GC2787@dhcp22.suse.cz> <20171220071500.GA11774@jagdpanzerIV>
From: A K <akaraliou.dev@gmail.com>
Message-ID: <04faff62-0944-3c7d-15b0-9dc60054a830@gmail.com>
Date: Wed, 20 Dec 2017 11:29:29 +0300
MIME-Version: 1.0
In-Reply-To: <20171220071500.GA11774@jagdpanzerIV>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, minchan@kernel.org, ngupta@vflare.org, linux-mm@kvack.org

On 12/20/2017 10:15 AM, Sergey Senozhatsky wrote:

>
> On (12/19/17 15:27), Andrew Morton wrote:
> > I did this:
> >
> > From: Andrew Morton <akpm@linux-foundation.org>
> > Subject: mm-zsmalloc-simplify-shrinker-init-destroy-fix
> >
> > update comment (Aliaksei), make zs_register_shrinker() return void
> >
> > Cc: Aliaksei Karaliou <akaraliou.dev@gmail.com>
> > Cc: Michal Hocko <mhocko@kernel.org>
> > Cc: Minchan Kim <minchan@kernel.org>
> > Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> > Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
>
> looks good. thanks!
>
> 	-ss
Thanks for updating the code, Andrew, but removing return from
zs_register_shrinker() leads to triggering of 'warn_unused_result'
from 'sparse' on the line where register_shrinker() is called
(which was recently marker as __must_check).

May we leave previous variant to avoid that ? Or it is not critical ?

Best regards,
    Aliaksei.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
