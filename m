Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 28E366B0078
	for <linux-mm@kvack.org>; Fri, 17 Sep 2010 10:22:04 -0400 (EDT)
Date: Fri, 17 Sep 2010 09:22:00 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Default zone_reclaim_mode = 1 on NUMA kernel is bad for
 file/email/web servers
In-Reply-To: <20100917140916.GA8474@brong.net>
Message-ID: <alpine.DEB.2.00.1009170916130.11900@router.home>
References: <1284349152.15254.1394658481@webmail.messagingengine.com> <20100916184240.3BC9.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1009161153210.22849@router.home> <1284684653.10161.1395434085@webmail.messagingengine.com> <1284703264.3408.1.camel@sli10-conroe.sh.intel.com>
 <1284708756.2702.1395472601@webmail.messagingengine.com> <alpine.DEB.2.00.1009170851200.11900@router.home> <20100917140916.GA8474@brong.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Bron Gondwana <brong@fastmail.fm>
Cc: Robert Mueller <robm@fastmail.fm>, Shaohua Li <shaohua.li@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Sat, 18 Sep 2010, Bron Gondwana wrote:

> > From the first look that seems to be the problem. You do not need to be
> > bound to a particular cpu, the scheduler will just leave a single process
> > on the same cpu by default. If you then allocate all memory only from this
> > process then you get the scenario that you described.
>
> Huh?  Which bit of forking server makes you think one process is allocating
> lots of memory?  They're opening and reading from files.  Unless you're
> calling the kernel a "single process".

I have no idea what your app does. The data that I glanced over looks as
if most allocations happen for a particular memory node and since the
memory is optimized to be local to that node other memory is not used
intensively. This can occur because of allocations through one process /
thread that is always running on the same cpu and therefore always
allocates from the memory node local to that cpu.

It can also happen f.e. if a driver always allocates memory local to the
I/O bus that it is using.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
