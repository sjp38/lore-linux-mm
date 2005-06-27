Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j5RIpCvN563662
	for <linux-mm@kvack.org>; Mon, 27 Jun 2005 14:51:13 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j5RIp8cC184030
	for <linux-mm@kvack.org>; Mon, 27 Jun 2005 12:51:11 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j5RIp7nb029612
	for <linux-mm@kvack.org>; Mon, 27 Jun 2005 12:51:08 -0600
Subject: RE: [rfc] lockless pagecache
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <200506271814.j5RIEwg22390@unix-os.sc.intel.com>
References: <200506271814.j5RIEwg22390@unix-os.sc.intel.com>
Content-Type: text/plain
Date: Mon, 27 Jun 2005 11:50:58 -0700
Message-Id: <1119898264.13376.89.camel@dyn9047017102.beaverton.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: 'Nick Piggin' <nickpiggin@yahoo.com.au>, Lincoln Dale <ltd@cisco.com>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2005-06-27 at 11:14 -0700, Chen, Kenneth W wrote:
> Nick Piggin wrote on Monday, June 27, 2005 2:04 AM
> > >> However I think for Oracle and others that use shared memory like
> > >> this, they are probably not doing linear access, so that would be a
> > >> net loss. I'm not completely sure (I don't have access to real loads
> > >> at the moment), but I would have thought those guys would have looked
> > >> into fault ahead if it were a possibility.
> > > 
> > > 
> > > i thought those guys used O_DIRECT - in which case, wouldn't the page 
> > > cache not be used?
> > > 
> > 
> > Well I think they do use O_DIRECT for their IO, but they need to
> > use the Linux pagecache for their shared memory - that shared
> > memory being the basis for their page cache. I think. Whatever
> > the setup I believe they have issues with the tree_lock, which is
> > why it was changed to an rwlock.
> 
> Typically shared memory is used as db buffer cache, and O_DIRECT is
> performed on these buffer cache (hence O_DIRECT on the shared memory).
> You must be thinking some other workload.  Nevertheless, for OLTP type
> of db workload, tree_lock hasn't been a problem so far.

What about DSS ? I need to go back and verify some of the profiles
we have.

Thanks,
Badari


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
