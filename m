Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 575FC6B0089
	for <linux-mm@kvack.org>; Wed, 16 Jul 2014 16:44:07 -0400 (EDT)
Received: by mail-wi0-f173.google.com with SMTP id f8so5986690wiw.12
        for <linux-mm@kvack.org>; Wed, 16 Jul 2014 13:44:06 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id ex9si557498wjd.176.2014.07.16.13.44.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jul 2014 13:44:05 -0700 (PDT)
Date: Wed, 16 Jul 2014 16:43:46 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: memcg swap doesn't work in mmotm-2014-07-09-17-08?
Message-ID: <20140716204346.GE8524@nhori.redhat.com>
References: <20140716181007.GA8524@nhori.redhat.com>
 <20140716183727.GB29639@cmpxchg.org>
 <20140716193129.GB8524@nhori.redhat.com>
 <20140716195721.GC29639@cmpxchg.org>
 <20140716201147.GD8524@nhori.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140716201147.GD8524@nhori.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, cgroups@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Wed, Jul 16, 2014 at 04:11:47PM -0400, Naoya Horiguchi wrote:
...
> > I was running on 3.16.0-rc5-mm1-00480-gab7ca1e1e407 (latest mmots).
> 
> I'll try this kernel.
> If that passes, this problem is fixed implicitly, so that's fine :)

Not reproduced in the latest mmots, so the problem is already fixed.

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
