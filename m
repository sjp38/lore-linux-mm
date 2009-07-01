Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id F2B066B004F
	for <linux-mm@kvack.org>; Wed,  1 Jul 2009 06:29:04 -0400 (EDT)
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp05.in.ibm.com (8.13.1/8.13.1) with ESMTP id n61ATrfW024556
	for <linux-mm@kvack.org>; Wed, 1 Jul 2009 15:59:53 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n61ATr1a2035894
	for <linux-mm@kvack.org>; Wed, 1 Jul 2009 15:59:53 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.13.1/8.13.3) with ESMTP id n61ATrRI017376
	for <linux-mm@kvack.org>; Wed, 1 Jul 2009 15:59:53 +0530
Date: Wed, 1 Jul 2009 15:59:51 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/10] Fix page_mkwrite() for blocksize < pagesize
	(version 3)
Message-ID: <20090701102951.GA23029@skywalker>
References: <1245088797-29533-1-git-send-email-jack@suse.cz> <20090616143424.GA22002@infradead.org> <20090616144217.GA18063@duck.suse.cz> <20090630174419.GA15102@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090630174419.GA15102@infradead.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

On Tue, Jun 30, 2009 at 01:44:19PM -0400, Christoph Hellwig wrote:
> On Tue, Jun 16, 2009 at 04:42:17PM +0200, Jan Kara wrote:
> >   Good point, I should have mentioned in the changelog: fsx-linux is able
> > to trigger the problem quite quickly.
> >   I have also written a simple program for initial testing of the fix
> > (works only for 1K blocksize and 4K pagesize) - it's attached.
> 
> I haven't been able to trigger anything with it on either xfs or ext4.
> 

fsx-linux with ext4 mount option -o nodelalloc.

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
