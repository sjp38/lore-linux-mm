Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id C7BFC6B004D
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 06:32:43 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nADBWeQj001758
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 13 Nov 2009 20:32:41 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C5CEC45DE4F
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 20:32:40 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id A6E0245DE4D
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 20:32:40 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8884D1DB8038
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 20:32:40 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3E83C1DB8037
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 20:32:40 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] Allow memory hotplug and hibernation in the same kernel
In-Reply-To: <20091113200745.33CE.A69D9226@jp.fujitsu.com>
References: <20091113105944.GA16028@basil.fritz.box> <20091113200745.33CE.A69D9226@jp.fujitsu.com>
Message-Id: <20091113203151.33D1.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 13 Nov 2009 20:32:39 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: kosaki.motohiro@jp.fujitsu.com, akpm@linux-foundation.org, linux-mm@kvack.org, gerald.schaefer@de.ibm.com, rjw@sisk.pl, linux-kernel@vger.kernel.org, Yasunori Goto <y-goto@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> (cc to goto-san)
> 
> > Allow memory hotplug and hibernation in the same kernel
> > 
> > Memory hotplug and hibernation was excluded in Kconfig. This is obviously
> > a problem for distribution kernels who want to support both in the same
> > image.
> 
> Sure.
> 
> This exclusion is nearly meaningless. if anybody remove cpu, memory and/or
> various peripheral from hibernated machine. the system might not resume.
> it's obvious. memory is not special.
> 
> Documentation/power/swsusp.txt explicitly said
> 
> 	 * BIG FAT WARNING *********************************************************
> 	 *
> 	 * If you touch anything on disk between suspend and resume...
> 	 *                              ...kiss your data goodbye.
> 
> 
> I like this patch.
> 
> 
> > 
> > After some discussions with Rafael and others the only problem is 
> > with parallel memory hotadd or removal while a hibernation operation
> > is in process. It was also working for s390 before.
> > 
> > This patch removes the Kconfig level exclusion, and simply
> > makes the memory add / remove functions grab the pm_mutex
> > to exclude against hibernation.
> > 
> > This is a 2.6.32 candidate.

2.6.32?




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
