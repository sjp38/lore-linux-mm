Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6B39E6B003D
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 04:17:00 -0400 (EDT)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e38.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n3S8EhnE030266
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 02:14:43 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n3S8HE4q084076
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 02:17:14 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n3S8HE3t002238
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 02:17:14 -0600
Subject: Re: meminfo Committed_AS underflows
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20090427202707.9d36ce8a.akpm@linux-foundation.org>
References: <20090415084713.GU7082@balbir.in.ibm.com>
	 <20090427132722.926b07f1.akpm@linux-foundation.org>
	 <20090428092400.EBB6.A69D9226@jp.fujitsu.com>
	 <20090427202707.9d36ce8a.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Tue, 28 Apr 2009 01:17:11 -0700
Message-Id: <1240906631.29485.75.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, balbir@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, ebmunson@us.ibm.com, mel@linux.vnet.ibm.com, cl@linux-foundation.org, stable@kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 2009-04-27 at 20:27 -0700, Andrew Morton wrote:
> There's potential here for weird performance regressions, so I think
> that if we do this in mainline, we should wait a while (a few weeks?)
> before backporting it.
> 
> Do we know how long this bug has existed for?  Quite a while, I
> expect?

Yeah, we didn't notice it until a recent enterprise distro got a config
with NR_CPUS=1024.  That opened the window up in a major way because of
the way we calculated the threshold.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
