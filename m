Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 07D079000BD
	for <linux-mm@kvack.org>; Fri, 23 Sep 2011 11:54:35 -0400 (EDT)
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e8.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p8NFdmlD022829
	for <linux-mm@kvack.org>; Fri, 23 Sep 2011 11:39:48 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p8NFsYMQ260726
	for <linux-mm@kvack.org>; Fri, 23 Sep 2011 11:54:34 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p8NFsWKo021655
	for <linux-mm@kvack.org>; Fri, 23 Sep 2011 11:54:33 -0400
Subject: Re: [RFC][PATCH] show page size in /proc/$pid/numa_maps
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <alpine.DEB.2.00.1109221339520.31548@chino.kir.corp.google.com>
References: <20110921221329.5B7EE5C5@kernel>
	 <alpine.DEB.2.00.1109221339520.31548@chino.kir.corp.google.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 23 Sep 2011 08:54:28 -0700
Message-ID: <1316793268.16137.481.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 2011-09-22 at 13:43 -0700, David Rientjes wrote:
> Why not just add a pagesize={4K,2M,1G,...} field for every output? 

I think it's a bit misleading.  With THP at least we have 2M pages in
the MMU, but we're reporting in 4k units.

I certainly considered doing just what you're suggesting, though.  It's
definitely not a bad idea.  Certainly much more clear.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
