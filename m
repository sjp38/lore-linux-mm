Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m1CNKiwE000332
	for <linux-mm@kvack.org>; Tue, 12 Feb 2008 18:20:44 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1CNKiAD185718
	for <linux-mm@kvack.org>; Tue, 12 Feb 2008 16:20:44 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1CNKhi1004656
	for <linux-mm@kvack.org>; Tue, 12 Feb 2008 16:20:44 -0700
Subject: Re: [-mm PATCH] register_memory/unregister_memory clean ups
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <1202857416.25604.71.camel@dyn9047017100.beaverton.ibm.com>
References: <20080211114818.74c9dcc7.akpm@linux-foundation.org>
	 <1202765553.25604.12.camel@dyn9047017100.beaverton.ibm.com>
	 <20080212154309.F9DA.Y-GOTO@jp.fujitsu.com>
	 <1202836953.25604.42.camel@dyn9047017100.beaverton.ibm.com>
	 <1202849972.11188.71.camel@nimitz.home.sr71.net>
	 <1202853415.25604.59.camel@dyn9047017100.beaverton.ibm.com>
	 <1202853434.11188.76.camel@nimitz.home.sr71.net>
	 <1202854031.25604.62.camel@dyn9047017100.beaverton.ibm.com>
	 <1202854520.11188.90.camel@nimitz.home.sr71.net>
	 <1202857416.25604.71.camel@dyn9047017100.beaverton.ibm.com>
Content-Type: text/plain
Date: Tue, 12 Feb 2008 15:20:48 -0800
Message-Id: <1202858448.11188.108.camel@nimitz.home.sr71.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: Yasunori Goto <y-goto@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, greg@kroah.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2008-02-12 at 15:03 -0800, Badari Pulavarty wrote:
> Here is the version with your suggestion. Do you like this better ?

I do like how it looks, better, thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
