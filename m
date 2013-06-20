Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 4B1756B0033
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 23:10:50 -0400 (EDT)
Message-ID: <1371697844.5739.29.camel@marge.simpson.net>
Subject: Re: [PATCH v2] Make transparent hugepages cpuset aware
From: Mike Galbraith <bitbucket@online.de>
Date: Thu, 20 Jun 2013 05:10:44 +0200
In-Reply-To: <alpine.DEB.2.02.1306191939250.24151@chino.kir.corp.google.com>
References: <1370967244-5610-1-git-send-email-athorlton@sgi.com>
	 <alpine.DEB.2.02.1306111517200.6141@chino.kir.corp.google.com>
	 <20130618164537.GJ16067@sgi.com>
	 <alpine.DEB.2.02.1306181654350.4503@chino.kir.corp.google.com>
	 <20130619093212.GX3658@sgi.com>
	 <alpine.DEB.2.02.1306191419081.13015@chino.kir.corp.google.com>
	 <20130620022739.GF3658@sgi.com>
	 <alpine.DEB.2.02.1306191939250.24151@chino.kir.corp.google.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Robin Holt <holt@sgi.com>, Alex Thorlton <athorlton@sgi.com>, linux-kernel@vger.kernel.org, Li Zefan <lizefan@huawei.com>, Rob Landley <rob@landley.net>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, linux-doc@vger.kernel.org, linux-mm@kvack.org

On Wed, 2013-06-19 at 19:43 -0700, David Rientjes wrote: 
>   
> I'm suspecting that you're referring to enlarged rss because of 
> khugepaged's max_ptes_none and because you're abusing the purpose of 
> cpusets for containerization.

Why is containerization an abuse?  What's wrong with renting out chunks
of a big box farm on the fly like a task motel?  If a realtime customer
checks in, he's not gonna be thrilled about sharing a room.

-Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
