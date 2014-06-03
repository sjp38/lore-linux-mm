Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id A5FFF6B0031
	for <linux-mm@kvack.org>; Tue,  3 Jun 2014 07:10:03 -0400 (EDT)
Received: by mail-wi0-f175.google.com with SMTP id f8so6179018wiw.8
        for <linux-mm@kvack.org>; Tue, 03 Jun 2014 04:10:01 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id da1si27698702wib.71.2014.06.03.04.10.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 03 Jun 2014 04:10:01 -0700 (PDT)
Date: Tue, 3 Jun 2014 13:09:59 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2 0/4] memcg: Low-limit reclaim
Message-ID: <20140603110959.GE1321@dhcp22.suse.cz>
References: <1398688005-26207-1-git-send-email-mhocko@suse.cz>
 <20140528121023.GA10735@dhcp22.suse.cz>
 <20140528134905.GF2878@cmpxchg.org>
 <20140528142144.GL9895@dhcp22.suse.cz>
 <20140528152854.GG2878@cmpxchg.org>
 <xr93ioopyj1y.fsf@gthelen.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <xr93ioopyj1y.fsf@gthelen.mtv.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michel Lespinasse <walken@google.com>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Roman Gushchin <klamm@yandex-team.ru>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>

On Wed 28-05-14 09:17:13, Greg Thelen wrote:
[...]
> My 2c...  The following works for my use cases:
> 1) introduce memory.low_limit_in_bytes (default=0 thus no default change
>    from older kernels)
> 2) interested users will set low_limit_in_bytes to non-zero value.
>    Memory protected by low limit should be as migratable/reclaimable as
>    mlock memory.  If a zone full of mlock memory causes oom kills, then
>    so should the low limit.

Would fallback mode in overcommit or the corner case situation break
your usecase?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
