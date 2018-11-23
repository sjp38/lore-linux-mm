Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id B413A6B3129
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 08:49:26 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id o21so2412439edq.4
        for <linux-mm@kvack.org>; Fri, 23 Nov 2018 05:49:26 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 4si1803263edh.154.2018.11.23.05.49.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Nov 2018 05:49:25 -0800 (PST)
Date: Fri, 23 Nov 2018 14:49:24 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm/slub: improve performance by skipping checked node
 in get_any_partial()
Message-ID: <20181123134924.GU8625@dhcp22.suse.cz>
References: <20181108011204.9491-1-richard.weiyang@gmail.com>
 <20181120033119.30013-1-richard.weiyang@gmail.com>
 <20181121190555.c010ac50e7eaa141549a63e5@linux-foundation.org>
 <20181122234159.5hrhxioe6b777ttb@master>
 <20181123133902.GS8625@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181123133902.GS8625@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, cl@linux.com, penberg@kernel.org, linux-mm@kvack.org

On Fri 23-11-18 14:39:02, Michal Hocko wrote:
> On Thu 22-11-18 23:41:59, Wei Yang wrote:
> > On Wed, Nov 21, 2018 at 07:05:55PM -0800, Andrew Morton wrote:
> [...]
> > >> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
> > 
> > Reviewed-by: Wei Yang <richard.weiyang@gmail.com>
> 
> Why would you want to add reviewed tag to your own patch? Isn't the
> s-o-b a sufficient sign of you being and author of the patch and
> therefore the one who has reviewed the change before asking for merging?

OK, it seems I've misunderstood. Did you mean Reviewed-by to the follow
up fixes by Andrew? If yes then sorry about my response. I do not want
to speak for Andrew but he usually just wants a "looks good" and will
eventually fold his changes into the original patch.
-- 
Michal Hocko
SUSE Labs
