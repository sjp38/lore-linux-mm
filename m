Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.12.10/8.12.10) with ESMTP id j191F2Pc005904
	for <linux-mm@kvack.org>; Tue, 8 Feb 2005 20:15:02 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j191F2uq282464
	for <linux-mm@kvack.org>; Tue, 8 Feb 2005 20:15:02 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11/8.12.11) with ESMTP id j191F1QW031640
	for <linux-mm@kvack.org>; Tue, 8 Feb 2005 20:15:02 -0500
Subject: Re: [Lhms-devel] [RFC][PATCH] no per-arch mem_map init
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20050208161218.883A.YGOTO@us.fujitsu.com>
References: <1107891434.4716.16.camel@localhost>
	 <20050208161218.883A.YGOTO@us.fujitsu.com>
Content-Type: text/plain
Date: Tue, 08 Feb 2005 17:14:35 -0800
Message-Id: <1107911675.4716.49.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <ygoto@us.fujitsu.com>
Cc: lhms <lhms-devel@lists.sourceforge.net>, Jesse Barnes <jbarnes@engr.sgi.com>, Bob Picco <bob.picco@hp.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2005-02-08 at 16:39 -0800, Yasunori Goto wrote:
> Hi Dave-san.
> 
> > This patch has been one of the base patches in the -mhp tree for a bit
> > now, and seems to be working pretty well, at least on x86.  I would like
> > to submit it upstream, but I want to get a bit more testing first.  Is
> > there a chance you ia64 guys could give it a quick test boot to make
> > sure that it doesn't screw you over?  
> 
> I tried this single patch with 2.6.11-rc2-mm2 on my Tiger4, and
> there is no problem in booting. In addition, I compliled other
> kernel as simple workload test on this test kernel, I didn't find
> any problem.

Thanks for the testing!

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
