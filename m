Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id BF6526B007D
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 13:42:04 -0400 (EDT)
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e2.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o8FHRFFX030850
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 13:27:15 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o8FHg2bD118916
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 13:42:02 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o8FHg1EN010525
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 13:42:01 -0400
Date: Wed, 15 Sep 2010 23:11:58 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH v2] After swapout/swapin private dirty mappings are
 reported clean in smaps
Message-ID: <20100915174157.GA22371@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20100915134724.C9EE.A69D9226@jp.fujitsu.com>
 <201009151034.22497.knikanth@suse.de>
 <20100915141710.C9F7.A69D9226@jp.fujitsu.com>
 <201009151201.11359.knikanth@suse.de>
 <20100915140911.GC4383@balbir.in.ibm.com>
 <alpine.LNX.2.00.1009151612450.28912@zhemvz.fhfr.qr>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1009151612450.28912@zhemvz.fhfr.qr>
Sender: owner-linux-mm@kvack.org
To: Richard Guenther <rguenther@suse.de>
Cc: Nikanth Karthikesan <knikanth@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michael Matz <matz@novell.com>, Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* Richard Guenther <rguenther@suse.de> [2010-09-15 16:14:17]:

> On Wed, 15 Sep 2010, Balbir Singh wrote:
> 
> > * Nikanth Karthikesan <knikanth@suse.de> [2010-09-15 12:01:11]:
> > 
> > > How? Current smaps information without this patch provides incorrect 
> > > information. Just because a private dirty page became part of swap cache, it 
> > > shown as clean and backed by a file. If it is shown as clean and backed by 
> > > swap then it is fine.
> > >
> > 
> > How is GDB using this information?  
> 
> GDB counts the number of dirty and swapped pages in a private mapping and
> based on that decides whether it needs to dump it to a core file or not.
> If there are no dirty or swapped pages gdb assumes it can reconstruct
> the mapping from the original backing file.  This way for example
> shared libraries do not end up in the core file.
>

Thanks for clarifying 

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
