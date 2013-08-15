Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 4DE816B0080
	for <linux-mm@kvack.org>; Thu, 15 Aug 2013 17:37:36 -0400 (EDT)
Date: Thu, 15 Aug 2013 16:37:34 -0500
From: Russ Anderson <rja@sgi.com>
Subject: Re: [PATCH] memblock, numa: Binary search node id
Message-ID: <20130815213734.GA28658@sgi.com>
Reply-To: Russ Anderson <rja@sgi.com>
References: <1376545589-32129-1-git-send-email-yinghai@kernel.org> <20130815134348.bb119a7987af0bb64ed77b7b@linux-foundation.org> <CAE9FiQUyGpmMP0VPE5ZrvDMLB-sdb0DzajGvB_KDt-ZnoJZhPg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAE9FiQUyGpmMP0VPE5ZrvDMLB-sdb0DzajGvB_KDt-ZnoJZhPg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yinghai Lu <yinghai@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, Aug 15, 2013 at 02:06:44PM -0700, Yinghai Lu wrote:
> On Thu, Aug 15, 2013 at 1:43 PM, Andrew Morton
> <akpm@linux-foundation.org> wrote:
> > On Wed, 14 Aug 2013 22:46:29 -0700 Yinghai Lu <yinghai@kernel.org> wrote:
> >
> >> Current early_pfn_to_nid() on arch that support memblock go
> >> over memblock.memory one by one, so will take too many try
> >> near the end.
> >>
> >> We can use existing memblock_search to find the node id for
> >> given pfn, that could save some time on bigger system that
> >> have many entries memblock.memory array.
> >
> > Looks nice.  I wonder how much difference it makes.
> 
> Russ said he would test on his 256 nodes system, but looks he never
> got chance.

I reserved time tonight on a couple big systems to measure
the performance difference.

Thanks,
-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
