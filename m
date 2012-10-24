Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 0F9E46B0044
	for <linux-mm@kvack.org>; Wed, 24 Oct 2012 16:28:47 -0400 (EDT)
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Wed, 24 Oct 2012 14:28:46 -0600
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 886773E4004E
	for <linux-mm@kvack.org>; Wed, 24 Oct 2012 14:28:42 -0600 (MDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q9OKSP4F085974
	for <linux-mm@kvack.org>; Wed, 24 Oct 2012 14:28:26 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q9OKSOPC015442
	for <linux-mm@kvack.org>; Wed, 24 Oct 2012 14:28:24 -0600
Message-ID: <50884F63.8030606@linux.vnet.ibm.com>
Date: Wed, 24 Oct 2012 13:28:19 -0700
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] add some drop_caches documentation and info messsge
References: <20121012125708.GJ10110@dhcp22.suse.cz> <20121023164546.747e90f6.akpm@linux-foundation.org> <20121024062938.GA6119@dhcp22.suse.cz> <20121024125439.c17a510e.akpm@linux-foundation.org>
In-Reply-To: <20121024125439.c17a510e.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>

On 10/24/2012 12:54 PM, Andrew Morton wrote:
> hmpf.  This patch worries me.  If there are people out there who are
> regularly using drop_caches because the VM sucks, it seems pretty
> obnoxious of us to go dumping stuff into their syslog.  What are they
> supposed to do?  Stop using drop_caches?

People use drop_caches because they _think_ the VM sucks, or they
_think_ they're "tuning" their system.  _They_ are supposed to stop
using drop_caches. :)

What kind of interface _is_ it in the first place?  Is it really a
production-level thing that we expect users to be poking at?  Or, is it
a rarely-used debugging and benchmarking knob which is fair game for us
to tweak like this?

Do we have any valid uses of drop_caches where the printk() would truly
_be_ disruptive?  Are those cases where we _also_ have real kernel bugs
or issues that we should be working?  If it disrupts them and they go to
their vendor or the community directly, it gives us at least a shot at
fixing the real problems (or fixing the "invalid" use).

Adding taint, making this a single-shot printk, or adding vmstat
counters are all good ideas.  I guess I think the disruption is a
feature because I hope it will draw some folks out of the woodwork.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
