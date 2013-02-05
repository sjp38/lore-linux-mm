Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 299F86B0002
	for <linux-mm@kvack.org>; Tue,  5 Feb 2013 09:08:55 -0500 (EST)
Date: Tue, 5 Feb 2013 15:08:52 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Support variable-sized huge pages
Message-ID: <20130205140852.GU30577@one.firstfloor.org>
References: <1359620590.1391.5.camel@kernel> <20130131105227.GI30577@one.firstfloor.org> <1360043326.2403.2.camel@kernel.cn.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1360043326.2403.2.camel@kernel.cn.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ric Mason <ric.masonn@gmail.com>
Cc: Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>

On Mon, Feb 04, 2013 at 11:48:46PM -0600, Ric Mason wrote:
> Hi Andi,
> On Thu, 2013-01-31 at 11:52 +0100, Andi Kleen wrote:
> > On Thu, Jan 31, 2013 at 02:23:10AM -0600, Ric Mason wrote:
> > > Hi all,
> > > 
> > > It seems that Andi's "Support more pagesizes for
> > > MAP_HUGETLB/SHM_HUGETLB" patch has already merged. According to the
> > > patch, x86 will support 2MB and 1GB huge pages. But I just see 
> > > hugepages-2048kB under /sys/kernel/mm/hugepages/ on my x86_32 PAE desktop.
> > > Where is 1GB huge pages?
> > 
> > 1GB pages are only supported under 64bit kernels, and also
> > only if you allocate them explicitely with boot options.
> 
> I am curious about how can buddy system alloc 1GB huge pages? the most
> order buddy system supports is 10. Could you explain to me? 

It can't, that is why you can only allocate them at boot time.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
