Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 58B606B00E9
	for <linux-mm@kvack.org>; Thu,  1 Mar 2012 06:43:04 -0500 (EST)
Date: Thu, 1 Mar 2012 11:42:54 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v2] bootmem/sparsemem: remove limit constraint in
 alloc_bootmem_section
Message-ID: <20120301114254.GH1199@suse.de>
References: <1330112038-18951-1-git-send-email-nacc@us.ibm.com>
 <20120228154732.GE1199@suse.de>
 <20120229181233.GF5136@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120229181233.GF5136@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <haveblue@us.ibm.com>, Anton Blanchard <anton@au1.ibm.com>, Paul Mackerras <paulus@samba.org>, Ben Herrenschmidt <benh@kernel.crashing.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

On Wed, Feb 29, 2012 at 10:12:33AM -0800, Nishanth Aravamudan wrote:
> <SNIP>
>
> Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
> 

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
