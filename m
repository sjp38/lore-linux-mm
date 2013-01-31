Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 909DB6B0008
	for <linux-mm@kvack.org>; Thu, 31 Jan 2013 05:52:29 -0500 (EST)
Date: Thu, 31 Jan 2013 11:52:27 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Support variable-sized huge pages
Message-ID: <20130131105227.GI30577@one.firstfloor.org>
References: <1359620590.1391.5.camel@kernel>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1359620590.1391.5.camel@kernel>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ric Mason <ric.masonn@gmail.com>
Cc: linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>

On Thu, Jan 31, 2013 at 02:23:10AM -0600, Ric Mason wrote:
> Hi all,
> 
> It seems that Andi's "Support more pagesizes for
> MAP_HUGETLB/SHM_HUGETLB" patch has already merged. According to the
> patch, x86 will support 2MB and 1GB huge pages. But I just see 
> hugepages-2048kB under /sys/kernel/mm/hugepages/ on my x86_32 PAE desktop.
> Where is 1GB huge pages?

1GB pages are only supported under 64bit kernels, and also
only if you allocate them explicitely with boot options.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
