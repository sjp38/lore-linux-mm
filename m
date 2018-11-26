Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 381796B42F2
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 12:44:06 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id i55so9559942ede.14
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 09:44:06 -0800 (PST)
Received: from outbound-smtp12.blacknight.com (outbound-smtp12.blacknight.com. [46.22.139.17])
        by mx.google.com with ESMTPS id 7-v6si609924eji.75.2018.11.26.09.44.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Nov 2018 09:44:04 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp12.blacknight.com (Postfix) with ESMTPS id 807171C2E7B
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 17:44:04 +0000 (GMT)
Date: Mon, 26 Nov 2018 17:44:02 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: Hackbench pipes regression bisected to PSI
Message-ID: <20181126174402.GR23260@techsingularity.net>
References: <20181126133420.GN23260@techsingularity.net>
 <20181126160724.GA21268@cmpxchg.org>
 <20181126165446.GQ23260@techsingularity.net>
 <20181126173218.GA22640@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20181126173218.GA22640@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tejun Heo <tj@kernel.org>, Peter Zijlstra <peterz@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org

On Mon, Nov 26, 2018 at 12:32:18PM -0500, Johannes Weiner wrote:
> On Mon, Nov 26, 2018 at 04:54:47PM +0000, Mel Gorman wrote:
> > On Mon, Nov 26, 2018 at 11:07:24AM -0500, Johannes Weiner wrote:
> > > @@ -509,6 +509,15 @@ config PSI
> > >  
> > >  	  Say N if unsure.
> > >  
> > > +config PSI_DEFAULT_DISABLED
> > > +	bool "Require boot parameter to enable pressure stall information tracking"
> > > +	default n
> > > +	depends on PSI
> > > +	help
> > > +	  If set, pressure stall information tracking will be disabled
> > > +	  per default but can be enabled through passing psi_enable=1
> > > +	  on the kernel commandline during boot.
> > > +
> > >  endmenu # "CPU/Task time and stats accounting"
> > >  
> > 
> > Should this default y on the basis that someone only wants the feature if
> > they are aware of it? This is not that important as CONFIG_PSI is disabled
> > by default and it's up to distribution maintainers to use their brain.
> 
> I went with the NUMA balancing example again here, which defaults to
> enabling the feature at boot time. IMO that makes sense, as somebody
> would presumably first read through the PSI help text, then decide y
> on that before being asked the second question. A "yes, but
> <stipulations>" for vendor kernels seems more appropriate than
> requiring a double yes for other users to simply get the feature.
> 

That's fair enough. The original NUMA balancing thinking was that it
should be enabled because there is a reasonable expectation that it
would improve performance regardless of user awareness. PSI is not
necessarily the same as it requires a consumer but I accept that a
distro maintainer should read the Kconfig text and figure it out.

I'll make sure the updated version gets tested, thanks.

-- 
Mel Gorman
SUSE Labs
