Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 927DB6B003D
	for <linux-mm@kvack.org>; Fri, 27 Feb 2009 01:37:29 -0500 (EST)
Date: Thu, 26 Feb 2009 22:37:13 -0800 (PST)
Message-Id: <20090226.223713.92203280.davem@davemloft.net>
Subject: Re: [PATCH 1/2] clean up for early_pfn_to_nid
From: David Miller <davem@davemloft.net>
In-Reply-To: <20090216095042.95f4a6d0.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090213142032.09b4a4da.akpm@linux-foundation.org>
	<20090213.221226.264144345.davem@davemloft.net>
	<20090216095042.95f4a6d0.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: kamezawa.hiroyu@jp.fujitsu.com
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kosaki.motohiro@jp.fujitsu.com, davem@davemlloft.net, heiko.carstens@de.ibm.com, stable@kernel.org
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Mon, 16 Feb 2009 09:50:42 +0900

> On Fri, 13 Feb 2009 22:12:26 -0800 (PST)
> David Miller <davem@davemloft.net> wrote:
> 
> > From: Andrew Morton <akpm@linux-foundation.org>
> > Date: Fri, 13 Feb 2009 14:20:32 -0800
> > 
> > > I queued these as
> > > 
> > > mm-clean-up-for-early_pfn_to_nid.patch
> > > mm-fix-memmap-init-for-handling-memory-hole.patch
> > > 
> > > and tagged them as needed-in-2.6.28.x.  I don't recall whether they are
> > > needed in earlier -stable releases?
> > 
> > Every kernel going back to at least 2.6.24 has this bug.  It's likely
> > been around even longer, I didn't bother checking.
> > 
> 
> Sparc64's one is broken from this commit.
> 
> 09337f501ebdd224cd69df6d168a5c4fe75d86fa
> sparc64: Kill CONFIG_SPARC32_COMPAT
> 
> CONFIG_NODES_SPAN_OTEHR_NODES is set and config allows following kind of NUMA
> This is requirements from powerpc.

Well, actually this means that what broke sparc64 was the addition of
NUMA support then.  Users could and were enabling these options
on sparc64 beforehand, I just updated defconfig to reflect the
fact that my workstation was NUMA capable :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
