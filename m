Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id C1A886B0038
	for <linux-mm@kvack.org>; Wed, 20 Dec 2017 04:08:30 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id l99so7065688wrc.18
        for <linux-mm@kvack.org>; Wed, 20 Dec 2017 01:08:30 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k12si12441516wrh.398.2017.12.20.01.08.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 20 Dec 2017 01:08:29 -0800 (PST)
Date: Wed, 20 Dec 2017 10:08:28 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm/zsmalloc: simplify shrinker init/destroy
Message-ID: <20171220090828.GB4831@dhcp22.suse.cz>
References: <20171219102213.GA435@jagdpanzerIV>
 <1513680552-9798-1-git-send-email-akaraliou.dev@gmail.com>
 <20171219151341.GC15210@dhcp22.suse.cz>
 <20171219152536.GA591@tigerII.localdomain>
 <20171219155815.GC2787@dhcp22.suse.cz>
 <20171220071500.GA11774@jagdpanzerIV>
 <04faff62-0944-3c7d-15b0-9dc60054a830@gmail.com>
 <20171220083403.GC11774@jagdpanzerIV>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171220083403.GC11774@jagdpanzerIV>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: A K <akaraliou.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, minchan@kernel.org, ngupta@vflare.org, linux-mm@kvack.org

On Wed 20-12-17 17:34:03, Sergey Senozhatsky wrote:
> On (12/20/17 11:29), A K wrote:
> [..]
> > May we leave previous variant to avoid that ? Or it is not critical ?
> 
> let's keep void zs_register_shrinker() and just suppress the
> register_shrinker() must_check warning.

I would just hope we simply drop the must_check nonsense.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
