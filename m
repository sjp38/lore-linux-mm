Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0B7236B01AC
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 12:01:07 -0400 (EDT)
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate1.de.ibm.com (8.13.1/8.13.1) with ESMTP id o5HG0sQP022645
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 16:00:54 GMT
Received: from d12av01.megacenter.de.ibm.com (d12av01.megacenter.de.ibm.com [9.149.165.212])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o5HG0nTU1216570
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 18:00:54 +0200
Received: from d12av01.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av01.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id o5HG0m9h032154
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 18:00:49 +0200
Date: Thu, 17 Jun 2010 18:00:48 +0200
From: Christof Schmitt <christof.schmitt@de.ibm.com>
Subject: Re: Current topics for LSF10/MM Summit 8-9 August in Boston
Message-ID: <20100617160048.GA11689@schmichrtp.mainz.de.ibm.com>
References: <1276721459.2847.399.camel@mulgrave.site>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1276721459.2847.399.camel@mulgrave.site>
Sender: owner-linux-mm@kvack.org
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: linux-scsi@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, lsf10-pc@lists.linuxfoundation.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 16, 2010 at 03:50:59PM -0500, James Bottomley wrote:
> Given that we're under two months out, I thought it would be time to
> post a summary of the topics we've collected so far (Nick will post the
> MM summit ones later).  Look this over, and if there's anything missing,
> propose it ... or if you have cross Storage/FS/MM topics, post them too.
> 
> Oh, and since we're not the most organised bunch, if you posted a topic
> and don't see it in the list, please resend ... we probably lost it in
> an email shuffle.
> 
> Current Filesystem Topics:
> 
> Alex Elder	Upstream maintainer for XFS, general discussion on FS/IO
> Aneesh Kumar	Rich-acl patches which work better with NFSv4 acl and CIFS acl
> Anshul Madan	reflink for NFS
> Chuck Lever	NFS/IPV6 and NFS O_DIRECT, Wu's read-ahead work, vitro perf tools
> Eric Sandeen	Advances in testing, TRIM/DISCARD/Alignment, writeback sanity
> James Lentini	reflink for NFS
> Jan Kara	Discuss/drive sanity review of writeback and general ext*/jbd 
> Michael Rubin	Writeback scaling
> Sage Weil	Statlite, generic interface for describing file striping for distributed FS, VFS scalability
> Al Viro	Sorting out d_revalidate and other dcache issues
> Coly Li		directory/large file scalability
> Sorin Faibish	Cache writeback discussion
> 
> Current Storage Topics:
> 
> Eric Seppanen	Next generation SSDs, performance implications on Linux I/O
> Boaz Harrosh	PNFS performance considerations, bio_list based/async raidN for generic use; stable pages for I/O
> FUJITA Tomonori	SCSI target mode, iSCSI, block layer SG (bsg), sg, IOMMU, DMA issues
> Hannes Reinecke	libfc/multipath/error handing
> James Smart	FCOE proposal for rework of the FC sysfs tree, work with Hannes on other transport/SCSI subsystem topics
> Jeff Moyer	IO scheduler
> Joel Becker	SAN management plugin
> Martin Petersen	Updates on DIF/DIX, TRIM/DISCARD/UNMAP, generic support for WRITE_SAME
> 
> Plus some MM summit ones which Nick will summarise.
[...]

What about the topic "Stable pages while IO"?
http://www.spinics.net/lists/linux-scsi/msg44074.html

Was it lost during the e-mail shuffle or will it be part of the MM topics?

Christof

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
