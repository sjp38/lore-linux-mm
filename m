Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 52A416B02BF
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 17:09:17 -0400 (EDT)
Date: Fri, 20 Aug 2010 05:09:07 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [TESTCASE] Clean pages clogging the VM
Message-ID: <20100819210907.GA22747@localhost>
References: <20100809133000.GB6981@wil.cx>
 <20100817195001.GA18817@linux.intel.com>
 <20100818141308.GD1779@cmpxchg.org>
 <20100818160613.GE9431@localhost>
 <20100818160731.GA15002@localhost>
 <20100819115106.GG1779@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100819115106.GG1779@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Li, Shaohua" <shaohua.li@intel.com>
List-ID: <linux-mm.kvack.org>

On Thu, Aug 19, 2010 at 07:51:06PM +0800, Johannes Weiner wrote:
> I am currently trying to get rid of all the congestion_wait() in the VM.
> They are used for different purposes, so they need different replacement
> mechanisms.
> 
> I saw Shaohua's patch to make congestion_wait() cleverer.  But I really
> think that congestion is not a good predicate in the first place.  Why
> would the VM care about IO _congestion_?  It needs a bunch of pages to
> complete IO, whether the writing device is congested is not really
> useful information at this point, I think.

I have the same feeling that the congestion_wait() calls are not
pertinent ones.  I'm glad to see people working on that exploring
all possible replacement schemes.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
