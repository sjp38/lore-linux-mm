Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f169.google.com (mail-yk0-f169.google.com [209.85.160.169])
	by kanga.kvack.org (Postfix) with ESMTP id CFCCD6B0038
	for <linux-mm@kvack.org>; Tue, 15 Sep 2015 12:33:39 -0400 (EDT)
Received: by ykdu9 with SMTP id u9so192186827ykd.2
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 09:33:39 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id cw8si21667000wib.62.2015.09.15.09.33.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Sep 2015 09:33:39 -0700 (PDT)
Date: Tue, 15 Sep 2015 18:33:27 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v3 2/2] memcg: punt high overage reclaim to
 return-to-userland path
Message-ID: <20150915163327.GA13232@cmpxchg.org>
References: <20150913185940.GA25369@htj.duckdns.org>
 <20150913190008.GB25369@htj.duckdns.org>
 <20150915074724.GE2858@cmpxchg.org>
 <20150915155355.GH2905@mtj.duckdns.org>
 <20150915161218.GA12032@cmpxchg.org>
 <20150915162253.GI2905@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150915162253.GI2905@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: akpm@linux-foundation.org, mhocko@kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, vdavydov@parallels.com, kernel-team@fb.com

On Tue, Sep 15, 2015 at 12:22:53PM -0400, Tejun Heo wrote:
> Hello,
> 
> On Tue, Sep 15, 2015 at 06:12:18PM +0200, Johannes Weiner wrote:
> > But they have been failing indefinitely forever once you hit the hard
> > limit in the past. There was never an async reclaim provision there.
> >
> > I can definitely see that the unconstrained high limit breaching needs
> > to be fixed one way or another, I just don't quite understand why you
> > chose to go for new semantics. Is there a new or a specific usecase
> > you had in mind when you chose deferred reclaim over simply failing?
> 
> Hmmm... so if we just fail, it breaks the assumptions that slab/slub
> is making and while they might not fail outright would behave in an
> undesirable way.  It's just that we didn't notice that before with
> limit_on_bytes and at least on the v2 interface the distinction
> between high and max makes the problem easy to deal with from high
> enforcement.

Gotcha, it makes sense to address this then. Thanks for clarifying.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
