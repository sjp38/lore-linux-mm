Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id A556F6B0069
	for <linux-mm@kvack.org>; Wed,  5 Sep 2012 05:07:49 -0400 (EDT)
Received: by pbbro12 with SMTP id ro12so654207pbb.14
        for <linux-mm@kvack.org>; Wed, 05 Sep 2012 02:07:49 -0700 (PDT)
Date: Wed, 5 Sep 2012 02:07:44 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC 0/5] forced comounts for cgroups.
Message-ID: <20120905090744.GG3195@dhcp-172-17-108-109.mtv.corp.google.com>
References: <1346768300-10282-1-git-send-email-glommer@parallels.com>
 <20120904214602.GA9092@dhcp-172-17-108-109.mtv.corp.google.com>
 <5047074D.1030104@parallels.com>
 <20120905081439.GC3195@dhcp-172-17-108-109.mtv.corp.google.com>
 <50470A87.1040701@parallels.com>
 <20120905082947.GD3195@dhcp-172-17-108-109.mtv.corp.google.com>
 <50470EBF.9070109@parallels.com>
 <20120905084740.GE3195@dhcp-172-17-108-109.mtv.corp.google.com>
 <50471379.3060603@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50471379.3060603@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, davej@redhat.com, ben@decadent.org.uk, a.p.zijlstra@chello.nl, pjt@google.com, lennart@poettering.net, kay.sievers@vrfy.org

Hello, Glauber.

On Wed, Sep 05, 2012 at 12:55:21PM +0400, Glauber Costa wrote:
> > So, I think it's desirable for all controllers to be able to handle
> > hierarchies the same way and to have the ability to tag something as
> > belonging to certain group in the hierarchy for all controllers but I
> > don't think it's desirable or feasible to require all of them to
> > follow exactly the same grouping at all levels.
> 
> By "different levels of granularity" do you mean having just a subset of
> them turned on at a particular place?

Heh, this is tricky to describe and I'm not really following what you
mean.  They're all on the same tree but a controller should be able to
handle a given subtree as single group.  e.g. if you draw the tree,
different controllers should be able to draw different enclosing
circles and operate on the simplifed tree.  How flexible that should
be, I don't know.  Maybe it would be enough to be able to say "treat
all children of this node as belonging to this node for controllers X
and Y".

> If yes, having them guaranteed to be comounted is still perceived by me
> as a good first step. A natural following would be to turn them on/off
> on a per-group basis.

I don't agree with that.  If we do it that way, we would lose
differing granularity from forcing co-mounting and then restore it
later when the subtree handling is implemented.  If we can do away
with differing granularity, that's fine; otherwise, it doesn't make
much sense to remove and then restore it.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
