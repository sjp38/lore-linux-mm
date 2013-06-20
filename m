Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 3BCA46B0033
	for <linux-mm@kvack.org>; Thu, 20 Jun 2013 16:37:39 -0400 (EDT)
Received: by mail-pb0-f49.google.com with SMTP id jt11so6602661pbb.22
        for <linux-mm@kvack.org>; Thu, 20 Jun 2013 13:37:38 -0700 (PDT)
Date: Thu, 20 Jun 2013 13:37:36 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2] Make transparent hugepages cpuset aware
In-Reply-To: <1371697844.5739.29.camel@marge.simpson.net>
Message-ID: <alpine.DEB.2.02.1306201334460.24145@chino.kir.corp.google.com>
References: <1370967244-5610-1-git-send-email-athorlton@sgi.com> <alpine.DEB.2.02.1306111517200.6141@chino.kir.corp.google.com> <20130618164537.GJ16067@sgi.com> <alpine.DEB.2.02.1306181654350.4503@chino.kir.corp.google.com> <20130619093212.GX3658@sgi.com>
 <alpine.DEB.2.02.1306191419081.13015@chino.kir.corp.google.com> <20130620022739.GF3658@sgi.com> <alpine.DEB.2.02.1306191939250.24151@chino.kir.corp.google.com> <1371697844.5739.29.camel@marge.simpson.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Galbraith <bitbucket@online.de>
Cc: Robin Holt <holt@sgi.com>, Alex Thorlton <athorlton@sgi.com>, linux-kernel@vger.kernel.org, Li Zefan <lizefan@huawei.com>, Rob Landley <rob@landley.net>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, linux-doc@vger.kernel.org, linux-mm@kvack.org

On Thu, 20 Jun 2013, Mike Galbraith wrote:

> > I'm suspecting that you're referring to enlarged rss because of 
> > khugepaged's max_ptes_none and because you're abusing the purpose of 
> > cpusets for containerization.
> 
> Why is containerization an abuse?  What's wrong with renting out chunks
> of a big box farm on the fly like a task motel?  If a realtime customer
> checks in, he's not gonna be thrilled about sharing a room.
> 

We "abused" cpusets for containerization for years, I'm not implying any 
negative connotation to it, see the 
Documentation/x86/x86_64/fake-numa-for-cpusets document that I wrote.  It 
doesn't suggest that we should be controlling thp through cpusets; if he's 
complaining about static binaries where he can't use a malloc hook then 
why not make it per-process so users don't have to configure cpusets to 
control it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
