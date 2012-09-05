Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id E55056B0068
	for <linux-mm@kvack.org>; Wed,  5 Sep 2012 05:19:31 -0400 (EDT)
Received: by pbbro12 with SMTP id ro12so673751pbb.14
        for <linux-mm@kvack.org>; Wed, 05 Sep 2012 02:19:31 -0700 (PDT)
Date: Wed, 5 Sep 2012 02:19:25 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC 0/5] forced comounts for cgroups.
Message-ID: <20120905091925.GJ3195@dhcp-172-17-108-109.mtv.corp.google.com>
References: <20120904214602.GA9092@dhcp-172-17-108-109.mtv.corp.google.com>
 <5047074D.1030104@parallels.com>
 <20120905081439.GC3195@dhcp-172-17-108-109.mtv.corp.google.com>
 <50470A87.1040701@parallels.com>
 <20120905082947.GD3195@dhcp-172-17-108-109.mtv.corp.google.com>
 <50470EBF.9070109@parallels.com>
 <20120905084740.GE3195@dhcp-172-17-108-109.mtv.corp.google.com>
 <1346835993.2600.9.camel@twins>
 <20120905091140.GH3195@dhcp-172-17-108-109.mtv.corp.google.com>
 <50471782.6060800@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50471782.6060800@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, davej@redhat.com, ben@decadent.org.uk, pjt@google.com, lennart@poettering.net, kay.sievers@vrfy.org

On Wed, Sep 05, 2012 at 01:12:34PM +0400, Glauber Costa wrote:
> > No, I never counted out differing granularity.
> 
> Can you elaborate on which interface do you envision to make it work?
> They will clearly be mounted in the same hierarchy, or as said
> alternatively, comounted.

I'm not sure yet.  At the simplest, mask of controllers which should
honor (or ignore) nesting beyond the node.  That should be
understandable enough.  Not sure whether that would be flexible enough
yet tho.  In the end, they should be comounted but again I don't think
enforcing comounting at the moment is a step towards that.  It's more
like a step sideways.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
