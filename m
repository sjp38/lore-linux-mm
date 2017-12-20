Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8CA256B0253
	for <linux-mm@kvack.org>; Wed, 20 Dec 2017 03:34:09 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id q12so9095834plk.16
        for <linux-mm@kvack.org>; Wed, 20 Dec 2017 00:34:09 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id q67sor1187705pga.246.2017.12.20.00.34.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Dec 2017 00:34:08 -0800 (PST)
Date: Wed, 20 Dec 2017 17:34:03 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v2] mm/zsmalloc: simplify shrinker init/destroy
Message-ID: <20171220083403.GC11774@jagdpanzerIV>
References: <20171219102213.GA435@jagdpanzerIV>
 <1513680552-9798-1-git-send-email-akaraliou.dev@gmail.com>
 <20171219151341.GC15210@dhcp22.suse.cz>
 <20171219152536.GA591@tigerII.localdomain>
 <20171219155815.GC2787@dhcp22.suse.cz>
 <20171220071500.GA11774@jagdpanzerIV>
 <04faff62-0944-3c7d-15b0-9dc60054a830@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <04faff62-0944-3c7d-15b0-9dc60054a830@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: A K <akaraliou.dev@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, minchan@kernel.org, ngupta@vflare.org, linux-mm@kvack.org

On (12/20/17 11:29), A K wrote:
[..]
> May we leave previous variant to avoid that ? Or it is not critical ?

let's keep void zs_register_shrinker() and just suppress the
register_shrinker() must_check warning.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
