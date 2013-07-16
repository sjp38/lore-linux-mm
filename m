From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm: vmstats: tlb flush counters
Date: Wed, 17 Jul 2013 07:36:32 +0800
Message-ID: <17652.6792500683$1374017810@news.gmane.org>
References: <20130716155304.AF1A88F8@viggo.jf.intel.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1UzEnS-0004Dd-QD
	for glkm-linux-mm-2@m.gmane.org; Wed, 17 Jul 2013 01:36:43 +0200
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id AF7CC6B0034
	for <linux-mm@kvack.org>; Tue, 16 Jul 2013 19:36:40 -0400 (EDT)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 17 Jul 2013 20:32:10 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 0A9BF2CE802D
	for <linux-mm@kvack.org>; Wed, 17 Jul 2013 09:36:34 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6GNaOwh6881642
	for <linux-mm@kvack.org>; Wed, 17 Jul 2013 09:36:24 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6GNaXqU024649
	for <linux-mm@kvack.org>; Wed, 17 Jul 2013 09:36:33 +1000
Content-Disposition: inline
In-Reply-To: <20130716155304.AF1A88F8@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org, Dave Hansen <dave@sr71.net>

On Tue, Jul 16, 2013 at 08:53:04AM -0700, Dave Hansen wrote:
>I was investigating some TLB flush scaling issues and realized
>that we do not have any good methods for figuring out how many
>TLB flushes we are doing.
>
>It would be nice to be able to do these in generic code, but the
>arch-independent calls don't explicitly specify whether we
>actually need to do remote flushes or not.  In the end, we really
>need to know if we actually _did_ global vs. local invalidations,
>so that leaves us with few options other than to muck with the
>counters from arch-specific code.
>
>Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
>

There is no context in the patch?

>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
