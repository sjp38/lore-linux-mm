Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id DD8BA6B0006
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 09:20:59 -0400 (EDT)
Received: from /spool/local
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rcjenn@linux.vnet.ibm.com>;
	Thu, 14 Mar 2013 23:18:56 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id AE9912CE804C
	for <linux-mm@kvack.org>; Fri, 15 Mar 2013 00:20:50 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r2EDKkaW43909342
	for <linux-mm@kvack.org>; Fri, 15 Mar 2013 00:20:47 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r2EDKm4t003726
	for <linux-mm@kvack.org>; Fri, 15 Mar 2013 00:20:49 +1100
Date: Thu, 14 Mar 2013 08:20:46 -0500
From: Robert Jennings <rcj@linux.vnet.ibm.com>
Subject: Re: zsmalloc limitations and related topics
Message-ID: <20130314132046.GA3172@linux.vnet.ibm.com>
References: <0efe9610-1aa5-4aa9-bde9-227acfa969ca@default>
 <20130313151359.GA3130@linux.vnet.ibm.com>
 <4ab899f6-208c-4d61-833c-d1e5e8b1e761@default>
 <514104D5.9020700@linux.vnet.ibm.com>
 <5141BC5D.9050005@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5141BC5D.9050005@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob <bob.liu@oracle.com>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, minchan@kernel.org, Nitin Gupta <nitingupta910@gmail.com>, Konrad Wilk <konrad.wilk@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Bob Liu <lliubbo@gmail.com>, Luigi Semenzato <semenzato@google.com>, Mel Gorman <mgorman@suse.de>

* Bob (bob.liu@oracle.com) wrote:
> On 03/14/2013 06:59 AM, Seth Jennings wrote:
> >On 03/13/2013 03:02 PM, Dan Magenheimer wrote:
> >>>From: Robert Jennings [mailto:rcj@linux.vnet.ibm.com]
> >>>Subject: Re: zsmalloc limitations and related topics
> >>
<snip>
> >>Yes.  And add pageframe-reclaim to this list of things that
> >>zsmalloc should do but currently cannot do.
> >
> >The real question is why is pageframe-reclaim a requirement?  What
> >operation needs this feature?
> >
> >AFAICT, the pageframe-reclaim requirements is derived from the
> >assumption that some external control path should be able to tell
> >zswap/zcache to evacuate a page, like the shrinker interface.  But this
> >introduces a new and complex problem in designing a policy that doesn't
> >shrink the zpage pool so aggressively that it is useless.
> >
> >Unless there is another reason for this functionality I'm missing.
> >
> 
> Perhaps it's needed if the user want to enable/disable the memory
> compression feature dynamically.
> Eg, use it as a module instead of recompile the kernel or even
> reboot the system.

To unload zswap all that is needed is to perform writeback on the pages
held in the cache, this can be done by extending the existing writeback
code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
