Received: from flecktone.americas.sgi.com (flecktone.americas.sgi.com [198.149.16.15])
	by omx1.americas.sgi.com (8.12.10/8.12.9/linux-outbound_gateway-1.1) with ESMTP id j28LFdxT018733
	for <linux-mm@kvack.org>; Tue, 8 Mar 2005 15:15:39 -0600
Received: from thistle-e236.americas.sgi.com (thistle-e236.americas.sgi.com [128.162.236.204])
	by flecktone.americas.sgi.com (8.12.9/8.12.10/SGI_generic_relay-1.2) with ESMTP id j28LFcR03561901
	for <linux-mm@kvack.org>; Tue, 8 Mar 2005 15:15:39 -0600 (CST)
Received: from lnx-holt.americas.sgi.com (IDENT:U2FsdGVkX1+qjmsanoTvno4yeXJsW24qadrEijEA9Oo@lnx-holt.americas.sgi.com [128.162.233.109]) by thistle-e236.americas.sgi.com (8.12.9/SGI-server-1.8) with ESMTP id j28LFctC22332018 for <linux-mm@kvack.org>; Tue, 8 Mar 2005 15:15:38 -0600 (CST)
Received: from lnx-holt.americas.sgi.com (localhost.localdomain [127.0.0.1])
	by lnx-holt.americas.sgi.com (8.13.1/8.12.11) with ESMTP id j28LFaRB016354
	for <linux-mm@kvack.org>; Tue, 8 Mar 2005 15:15:38 -0600
Received: (from holt@localhost)
	by lnx-holt.americas.sgi.com (8.13.1/8.13.1/Submit) id j28LFZqU016353
	for linux-mm@kvack.org; Tue, 8 Mar 2005 15:15:35 -0600
Date: Tue, 8 Mar 2005 15:15:35 -0600
From: Robin Holt <holt@sgi.com>
Subject: Is there a way to do an architecture specific shake of memory?
Message-ID: <20050308211535.GB16061@lnx-holt.americas.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I am in the process of fixing the quicklist handling for the ia64 page
tables.  The problem we are running into is the quicklists are per-cpu.
When memory is running short, the only current callout to shrink the
quicklist is coming from cpu_idle().  The most recent suggestion is to
schedule_delayed_work_on() for every cpu in the system and have them
check to see if the quicklist needs to be shrunk.  This feels wrong.

What I would like to do is have wakup_kswapd(), kswapd() or
balance_pdgat() do the actual call to smp_call_function_single() as
needed to try to shrink the quicklists.  This would need to be an ia64
only change.  Is there already a method for the architecture to get
control during any part of the process?  If not, where would be the most
acceptable place?

Any suggestions are welcome.

Thanks,
Robin Holt
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
