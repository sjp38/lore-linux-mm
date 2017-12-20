Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7E8FE6B0069
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 20:01:04 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id m39so6888258plg.19
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 17:01:04 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id a8sor5942913ple.14.2017.12.19.17.01.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Dec 2017 17:01:03 -0800 (PST)
Date: Wed, 20 Dec 2017 10:00:58 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v2] mm/zsmalloc: simplify shrinker init/destroy
Message-ID: <20171220010058.GB21976@jagdpanzerIV>
References: <20171219102213.GA435@jagdpanzerIV>
 <1513680552-9798-1-git-send-email-akaraliou.dev@gmail.com>
 <20171219151341.GC15210@dhcp22.suse.cz>
 <20171219152536.GA591@tigerII.localdomain>
 <20171219155815.GC2787@dhcp22.suse.cz>
 <15c19718-c08e-e7f6-8af9-9651db1b11cc@gmail.com>
 <20171219152736.55d064945a68d2d2ffc64b15@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171219152736.55d064945a68d2d2ffc64b15@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Aliaksei Karaliou <akaraliou.dev@gmail.com>, Michal Hocko <mhocko@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, linux-mm@kvack.org

On (12/19/17 15:27), Andrew Morton wrote:
> I did this:
> 
> From: Andrew Morton <akpm@linux-foundation.org>
> Subject: mm-zsmalloc-simplify-shrinker-init-destroy-fix
> 
> update comment (Aliaksei), make zs_register_shrinker() return void
> 
> Cc: Aliaksei Karaliou <akaraliou.dev@gmail.com>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

looks good. thanks!

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
