Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f173.google.com (mail-we0-f173.google.com [74.125.82.173])
	by kanga.kvack.org (Postfix) with ESMTP id 098126B0096
	for <linux-mm@kvack.org>; Wed, 16 Jul 2014 17:26:18 -0400 (EDT)
Received: by mail-we0-f173.google.com with SMTP id q58so1556726wes.4
        for <linux-mm@kvack.org>; Wed, 16 Jul 2014 14:26:18 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id h9si5390828wiz.69.2014.07.16.14.26.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 16 Jul 2014 14:26:17 -0700 (PDT)
Date: Wed, 16 Jul 2014 17:26:11 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: memcg swap doesn't work in mmotm-2014-07-09-17-08?
Message-ID: <20140716212611.GD29639@cmpxchg.org>
References: <20140716181007.GA8524@nhori.redhat.com>
 <20140716183727.GB29639@cmpxchg.org>
 <20140716193129.GB8524@nhori.redhat.com>
 <20140716195721.GC29639@cmpxchg.org>
 <20140716201147.GD8524@nhori.redhat.com>
 <20140716204346.GE8524@nhori.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140716204346.GE8524@nhori.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, cgroups@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Wed, Jul 16, 2014 at 04:43:46PM -0400, Naoya Horiguchi wrote:
> On Wed, Jul 16, 2014 at 04:11:47PM -0400, Naoya Horiguchi wrote:
> ...
> > > I was running on 3.16.0-rc5-mm1-00480-gab7ca1e1e407 (latest mmots).
> > 
> > I'll try this kernel.
> > If that passes, this problem is fixed implicitly, so that's fine :)
> 
> Not reproduced in the latest mmots, so the problem is already fixed.

Thanks for making sure, Naoya-san!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
