Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 1AAB76B0093
	for <linux-mm@kvack.org>; Wed,  5 Sep 2012 05:22:22 -0400 (EDT)
Received: by dadi14 with SMTP id i14so251577dad.14
        for <linux-mm@kvack.org>; Wed, 05 Sep 2012 02:22:21 -0700 (PDT)
Date: Wed, 5 Sep 2012 02:22:16 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC 0/5] forced comounts for cgroups.
Message-ID: <20120905092216.GK3195@dhcp-172-17-108-109.mtv.corp.google.com>
References: <1346768300-10282-1-git-send-email-glommer@parallels.com>
 <20120904214602.GA9092@dhcp-172-17-108-109.mtv.corp.google.com>
 <5047074D.1030104@parallels.com>
 <20120905081439.GC3195@dhcp-172-17-108-109.mtv.corp.google.com>
 <50470A87.1040701@parallels.com>
 <20120905082947.GD3195@dhcp-172-17-108-109.mtv.corp.google.com>
 <50470EBF.9070109@parallels.com>
 <20120905084740.GE3195@dhcp-172-17-108-109.mtv.corp.google.com>
 <1346835993.2600.9.camel@twins>
 <1346836041.2600.10.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1346836041.2600.10.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Glauber Costa <glommer@parallels.com>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, davej@redhat.com, ben@decadent.org.uk, pjt@google.com, lennart@poettering.net, kay.sievers@vrfy.org

Hey,

On Wed, Sep 05, 2012 at 11:07:21AM +0200, Peter Zijlstra wrote:
> Glauber, the other approach is sending a patch that doesn't touch
> cgroup.c but only the controllers and I'll merge it regardless of what
> tj thinks.
> 
> We need some movement here.

Peter, I don't think the proposed patch is helpful at this point.
While movement is necessary, it's not like moving towards any
direction is helpful.  They might just become another cruft which
needs to be maintained.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
