Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3D4CB6B0078
	for <linux-mm@kvack.org>; Fri, 17 Sep 2010 03:32:38 -0400 (EDT)
Message-Id: <1284708756.2702.1395472601@webmail.messagingengine.com>
From: "Robert Mueller" <robm@fastmail.fm>
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset="us-ascii"
In-Reply-To: <1284703264.3408.1.camel@sli10-conroe.sh.intel.com>
References: <1284349152.15254.1394658481@webmail.messagingengine.com>
 <20100916184240.3BC9.A69D9226@jp.fujitsu.com>
 <alpine.DEB.2.00.1009161153210.22849@router.home>
 <1284684653.10161.1395434085@webmail.messagingengine.com>
 <1284703264.3408.1.camel@sli10-conroe.sh.intel.com>
Reply-To: robm@fastmail.fm
Subject: Re: Default zone_reclaim_mode = 1 on NUMA kernel is bad for
 file/email/web servers
Date: Fri, 17 Sep 2010 17:32:36 +1000
Sender: owner-linux-mm@kvack.org
To: Shaohua Li <shaohua.li@intel.com>
Cc: Christoph Lameter <cl@linux.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Bron Gondwana <brong@fastmail.fm>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

> > I don't think this is any fault of how the software works. It's a
> > *very* standard "pre-fork child processes, allocate incoming
> > connections to a child process, open and mmap one or more files to
> > read data from them". That's not exactly a weird programming model,
> > and it's bad that the kernel is handling that case very badly with
> > everything default.
>
> maybe you incoming connection always happen on one CPU and you do the
> page allocation in that cpu, so some nodes use out of memory but
> others have a lot free. Try bind the child process to different nodes
> might help.

There's are 5000+ child processes (it's a cyrus IMAP server). Neither
the parent of any of the children are bound to any particular CPU. It
uses a standard fcntl lock to make sure only one spare child at a time
calls accept(). I don't think that's the problem.

Rob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
