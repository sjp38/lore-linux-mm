Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 7A3906B0078
	for <linux-mm@kvack.org>; Thu, 18 Feb 2010 14:38:16 -0500 (EST)
Date: Thu, 18 Feb 2010 13:37:35 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 05/12] Memory compaction core
In-Reply-To: <20100216145943.GA997@csn.ul.ie>
Message-ID: <alpine.DEB.2.00.1002181335270.7351@router.home>
References: <1265976059-7459-1-git-send-email-mel@csn.ul.ie> <1265976059-7459-6-git-send-email-mel@csn.ul.ie> <20100216170014.7309.A69D9226@jp.fujitsu.com> <20100216084800.GC26086@csn.ul.ie> <alpine.DEB.2.00.1002160849460.18275@router.home>
 <20100216145943.GA997@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, 16 Feb 2010, Mel Gorman wrote:

> > Oh there are numerous ZONE_DMA pressure issues if you have ancient /
> > screwed up hardware that can only operate on DMA or DMA32 memory.
> >
>
> I've never ran into the issue. I was under the impression that the only
> device that might care these days are floopy disks.

Kame-san had an issue a year or so ago.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
