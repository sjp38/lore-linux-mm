Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 35A746B007D
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 10:47:59 -0400 (EDT)
Subject: Re: [PATCH v2] After swapout/swapin private dirty mappings are
 reported clean in smaps
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <alpine.LNX.2.00.1009151612450.28912@zhemvz.fhfr.qr>
References: <20100915134724.C9EE.A69D9226@jp.fujitsu.com>
	 <201009151034.22497.knikanth@suse.de>
	 <20100915141710.C9F7.A69D9226@jp.fujitsu.com>
	 <201009151201.11359.knikanth@suse.de>
	 <20100915140911.GC4383@balbir.in.ibm.com>
	 <alpine.LNX.2.00.1009151612450.28912@zhemvz.fhfr.qr>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 15 Sep 2010 09:46:22 -0500
Message-ID: <1284561982.21906.280.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Richard Guenther <rguenther@suse.de>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Nikanth Karthikesan <knikanth@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michael Matz <matz@novell.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 2010-09-15 at 16:14 +0200, Richard Guenther wrote:
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

This whole discussion is a little disturbing.

The page is being reported clean as per the kernel's definition of
clean, full stop.

So either there's a latent bug/inconsistency in the kernel VM or
external tools are misinterpreting this data. But smaps is just
reporting what's there, the fault doesn't lie in smaps. So fixing smaps
just hides the problem, wherever it is.

Richard's report that the page is still clean after swapoff suggests the
inconsistency lies in the VM.

-- 
Mathematics is the supreme nostalgia of our time.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
