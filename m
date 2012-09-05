Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 89A136B005D
	for <linux-mm@kvack.org>; Wed,  5 Sep 2012 05:32:10 -0400 (EDT)
Received: by dadi14 with SMTP id i14so258851dad.14
        for <linux-mm@kvack.org>; Wed, 05 Sep 2012 02:32:09 -0700 (PDT)
Date: Wed, 5 Sep 2012 02:32:04 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC 0/5] forced comounts for cgroups.
Message-ID: <20120905093204.GL3195@dhcp-172-17-108-109.mtv.corp.google.com>
References: <1346768300-10282-1-git-send-email-glommer@parallels.com>
 <20120904214602.GA9092@dhcp-172-17-108-109.mtv.corp.google.com>
 <5047074D.1030104@parallels.com>
 <20120905081439.GC3195@dhcp-172-17-108-109.mtv.corp.google.com>
 <50470A87.1040701@parallels.com>
 <20120905082947.GD3195@dhcp-172-17-108-109.mtv.corp.google.com>
 <50470EBF.9070109@parallels.com>
 <20120905084740.GE3195@dhcp-172-17-108-109.mtv.corp.google.com>
 <1346835993.2600.9.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1346835993.2600.9.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Glauber Costa <glommer@parallels.com>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, davej@redhat.com, ben@decadent.org.uk, pjt@google.com, lennart@poettering.net, kay.sievers@vrfy.org

Hey, again.

On Wed, Sep 05, 2012 at 11:06:33AM +0200, Peter Zijlstra wrote:
> Doing all this runtime is just going to make the mess even bigger,
> because now we have to deal with even more stupid cases.
> 
> So either we go and try to contain this mess as proposed by Glauber or
> we go delete controllers.. I've had it with this crap.

cpuacct is rather unique tho.  I think it's gonna be silly whether the
hierarchy is unified or not.

1. If they always can live on the exact same hierarchy, there's no
   point in having the two separate.  Just merge them.

2. If they need differing levels of granularity, they either need to
   do it completely separately as they do now or have some form of
   dynamic optimization if absolutely necesary.

So, I think that choice is rather separate from other issues.  If
cpuacct is gonna be kept, I'd just keep it separate and warn that it
incurs extra overhead for the current users if for nothing else.
Otherwise, kill it or merge it into cpu.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
