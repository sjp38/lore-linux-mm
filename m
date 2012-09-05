Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id A024E6B0068
	for <linux-mm@kvack.org>; Wed,  5 Sep 2012 04:14:45 -0400 (EDT)
Received: by dadi14 with SMTP id i14so205010dad.14
        for <linux-mm@kvack.org>; Wed, 05 Sep 2012 01:14:45 -0700 (PDT)
Date: Wed, 5 Sep 2012 01:14:39 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC 0/5] forced comounts for cgroups.
Message-ID: <20120905081439.GC3195@dhcp-172-17-108-109.mtv.corp.google.com>
References: <1346768300-10282-1-git-send-email-glommer@parallels.com>
 <20120904214602.GA9092@dhcp-172-17-108-109.mtv.corp.google.com>
 <5047074D.1030104@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5047074D.1030104@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, davej@redhat.com, ben@decadent.org.uk, a.p.zijlstra@chello.nl, pjt@google.com, lennart@poettering.net, kay.sievers@vrfy.org

Hello, Glauber.

On Wed, Sep 05, 2012 at 12:03:25PM +0400, Glauber Costa wrote:
> The goal here is to have distributions to do it, because they tend to
> have a well defined lifecycle management, much more than upstream. Whoever
> sets this option, can coordinate with upstream.

Distros can just co-mount them during boot.  What's the point of the
config options?

> > Also, I really don't see much point in enforcing this almost arbitrary
> > grouping of controllers.  It doesn't simplify anything and using
> > cpuacct in more granular way than cpu actually is one of the better
> > justified use of multiple hierarchies.  Also, what about memcg and
> > blkcg?  Do they *really* coincide?  Note that both blkcg and memcg
> > involve non-trivial overhead and blkcg is essentially broken
> > hierarchy-wise.
> 
> Where did I mention memcg or blkcg in this patch ?

Differing hierarchies in memcg and blkcg currently is the most
prominent case where the intersection in writeback is problematic and
your proposed solution doesn't help one way or the other.  What's the
point?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
