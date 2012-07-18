Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id D1CA46B005C
	for <linux-mm@kvack.org>; Wed, 18 Jul 2012 17:38:11 -0400 (EDT)
Date: Wed, 18 Jul 2012 14:38:10 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: +
 memory-hotplug-fix-kswapd-looping-forever-problem-fix-fix.patch added to
 -mm tree
Message-Id: <20120718143810.b15564b3.akpm@linux-foundation.org>
In-Reply-To: <20120718012200.GA27770@bbox>
References: <20120717233115.A8E411E005C@wpzn4.hot.corp.google.com>
	<20120718012200.GA27770@bbox>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Ralf Baechle <ralf@linux-mips.org>, aaditya.kumar.30@gmail.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org

On Wed, 18 Jul 2012 10:22:00 +0900
Minchan Kim <minchan@kernel.org> wrote:

> > 
> > Is this really necessary?  Does the zone start out all-zeroes?  If not, can we
> > make it do so?
> 
> Good point.
> It can remove zap_zone_vm_stats and zone->flags = 0, too.
> More important thing is that we could remove adding code to initialize
> zero whenever we add new field to zone. So I look at the code.
> 
> In summary, IMHO, all is already initialie zero out but we need double
> check in mips.
> 

Well, this is hardly a performance-critical path.  So rather than
groveling around ensuring that each and every architectures does the
right thing, would it not be better to put a single memset() into core
MM if there is an appropriate place?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
