Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j3IHqB4u005673
	for <linux-mm@kvack.org>; Mon, 18 Apr 2005 13:52:11 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j3IHqAZd096124
	for <linux-mm@kvack.org>; Mon, 18 Apr 2005 13:52:11 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11/8.12.11) with ESMTP id j3IHq9aG017922
	for <linux-mm@kvack.org>; Mon, 18 Apr 2005 13:52:10 -0400
Subject: Re: [PATCH]: VM 3/8 PG_skipped
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <Pine.LNX.4.61.0504181111390.8456@chimarrao.boston.redhat.com>
References: <16994.40579.617974.423522@gargle.gargle.HOWL>
	 <Pine.LNX.4.61.0504181111390.8456@chimarrao.boston.redhat.com>
Content-Type: text/plain
Date: Mon, 18 Apr 2005 10:51:52 -0700
Message-Id: <1113846712.10810.111.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Nikita Danilov <nikita@clusterfs.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2005-04-18 at 11:12 -0400, Rik van Riel wrote:
> On Sun, 17 Apr 2005, Nikita Danilov wrote:
> 
> > Don't call ->writepage from VM scanner when page is met for the first time
> > during scan.
> 
> > Reason behind this is that ->writepages() will perform more efficient 
> > writeout than ->writepage(). Skipping of page can be conditioned on 
> > zone->pressure.
> 
> Agreed, in order to write out blocks of pages at once from
> the pageout code, we'll need to wait with writing until the
> dirty bit has been propagated from the ptes to the pages.

Is there a way to do this without consuming a page->flags bit?  We're
starting to run really low on them.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
