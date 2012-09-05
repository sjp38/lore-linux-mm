Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 2BD136B005D
	for <linux-mm@kvack.org>; Wed,  5 Sep 2012 04:47:46 -0400 (EDT)
Received: by pbbro12 with SMTP id ro12so622043pbb.14
        for <linux-mm@kvack.org>; Wed, 05 Sep 2012 01:47:45 -0700 (PDT)
Date: Wed, 5 Sep 2012 01:47:40 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC 0/5] forced comounts for cgroups.
Message-ID: <20120905084740.GE3195@dhcp-172-17-108-109.mtv.corp.google.com>
References: <1346768300-10282-1-git-send-email-glommer@parallels.com>
 <20120904214602.GA9092@dhcp-172-17-108-109.mtv.corp.google.com>
 <5047074D.1030104@parallels.com>
 <20120905081439.GC3195@dhcp-172-17-108-109.mtv.corp.google.com>
 <50470A87.1040701@parallels.com>
 <20120905082947.GD3195@dhcp-172-17-108-109.mtv.corp.google.com>
 <50470EBF.9070109@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50470EBF.9070109@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, davej@redhat.com, ben@decadent.org.uk, a.p.zijlstra@chello.nl, pjt@google.com, lennart@poettering.net, kay.sievers@vrfy.org

Hello, Glauber.

On Wed, Sep 05, 2012 at 12:35:11PM +0400, Glauber Costa wrote:
> > As long as cpuacct and cpu are separate, I think it makes sense to
> > assume that they at least could be at different granularity.  
> 
> If they are comounted, and more: forceably comounted, I don't see how to
> call them separate. At the very best, they are this way for
> compatibility purposes only, to lay a path that would allow us to get
> rid of the separation eventually.

I think this is where we disagree.  I didn't mean that all controllers
should be using exactly the same hierarchy when I was talking about
unified hierarchy.  I do think it's useful and maybe even essential to
allow differing levels of granularity.  cpu and cpuacct could be a
valid example for this.  Likely blkcg and memcg too.

So, I think it's desirable for all controllers to be able to handle
hierarchies the same way and to have the ability to tag something as
belonging to certain group in the hierarchy for all controllers but I
don't think it's desirable or feasible to require all of them to
follow exactly the same grouping at all levels.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
