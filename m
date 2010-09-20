Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3A5126B0047
	for <linux-mm@kvack.org>; Mon, 20 Sep 2010 01:21:36 -0400 (EDT)
From: Nikanth Karthikesan <knikanth@suse.de>
Subject: Re: [PATCH v2] After swapout/swapin private dirty mappings are reported clean in smaps
Date: Mon, 20 Sep 2010 10:54:01 +0530
References: <20100915134724.C9EE.A69D9226@jp.fujitsu.com> <alpine.LNX.2.00.1009151612450.28912@zhemvz.fhfr.qr> <201009192307.09309.knikanth@suse.de>
In-Reply-To: <201009192307.09309.knikanth@suse.de>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201009201054.02143.knikanth@suse.de>
Sender: owner-linux-mm@kvack.org
To: Richard Guenther <rguenther@suse.de>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michael Matz <matz@novell.com>, Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sunday 19 September 2010 23:07:09 Nikanth Karthikesan wrote:
> On Wednesday 15 September 2010 19:44:17 Richard Guenther wrote:
> > On Wed, 15 Sep 2010, Balbir Singh wrote:
> > > * Nikanth Karthikesan <knikanth@suse.de> [2010-09-15 12:01:11]:
> > > > How? Current smaps information without this patch provides incorrect
> > > > information. Just because a private dirty page became part of swap
> > > > cache, it shown as clean and backed by a file. If it is shown as
> > > > clean and backed by swap then it is fine.
> > >
> > > How is GDB using this information?
> >
> > GDB counts the number of dirty and swapped pages in a private mapping and
> > based on that decides whether it needs to dump it to a core file or not.
> > If there are no dirty or swapped pages gdb assumes it can reconstruct
> > the mapping from the original backing file.  This way for example
> > shared libraries do not end up in the core file.
> 
> Well, may be /proc/pid/pagemap + /proc/kpageflags is enough for this! One
>  can get the pageflags using these interfaces. See
>  Documentation/vm/pagemap.txt for the explanation on how to do it. There is
>  also a sample program that prints page flags using this interface in
>  Documentation/vm/page-types.c.
> 
> It is bad that /proc/pid/pagemap is never mentioned in
> Documentation/filesystems/proc.txt. I will send a patch to rectify this.

Or even simpler, /proc/pid/numa_maps already exports the number of anonymous 
pages in a mapping, if you have CONFIG_NUMA=y! Again not documented in 
Documentation/filesystems/proc.txt

Thanks
Nikanth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
