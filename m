Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id DD52F6B004A
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 10:14:33 -0400 (EDT)
Date: Wed, 15 Sep 2010 16:14:17 +0200 (CEST)
From: Richard Guenther <rguenther@suse.de>
Subject: Re: [PATCH v2] After swapout/swapin private dirty mappings are
 reported clean in smaps
In-Reply-To: <20100915140911.GC4383@balbir.in.ibm.com>
Message-ID: <alpine.LNX.2.00.1009151612450.28912@zhemvz.fhfr.qr>
References: <20100915134724.C9EE.A69D9226@jp.fujitsu.com> <201009151034.22497.knikanth@suse.de> <20100915141710.C9F7.A69D9226@jp.fujitsu.com> <201009151201.11359.knikanth@suse.de> <20100915140911.GC4383@balbir.in.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Nikanth Karthikesan <knikanth@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michael Matz <matz@novell.com>, Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 15 Sep 2010, Balbir Singh wrote:

> * Nikanth Karthikesan <knikanth@suse.de> [2010-09-15 12:01:11]:
> 
> > How? Current smaps information without this patch provides incorrect 
> > information. Just because a private dirty page became part of swap cache, it 
> > shown as clean and backed by a file. If it is shown as clean and backed by 
> > swap then it is fine.
> >
> 
> How is GDB using this information?  

GDB counts the number of dirty and swapped pages in a private mapping and
based on that decides whether it needs to dump it to a core file or not.
If there are no dirty or swapped pages gdb assumes it can reconstruct
the mapping from the original backing file.  This way for example
shared libraries do not end up in the core file.

Richard.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
