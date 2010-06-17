Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 0681A6B01AF
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 02:35:20 -0400 (EDT)
Subject: Re: Current topics for LSF10/MM Summit 8-9 August in Boston
From: "Nicholas A. Bellinger" <nab@linux-iscsi.org>
In-Reply-To: <1276721459.2847.399.camel@mulgrave.site>
References: <1276721459.2847.399.camel@mulgrave.site>
Content-Type: text/plain
Date: Wed, 16 Jun 2010 23:35:16 -0700
Message-Id: <1276756516.12514.272.camel@haakon2.linux-iscsi.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: linux-scsi@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, lsf10-pc@lists.linuxfoundation.org
List-ID: <linux-mm.kvack.org>

On Wed, 2010-06-16 at 15:50 -0500, James Bottomley wrote:
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
> 

Greeting James and co,

I noticed that the bit wrt to the kernel level target mode fabric
independent configfs infrastructure is not mentioned in the above..

http://marc.info/?l=linux-scsi&m=127010303618447&w=2

Where would this best fit in..?

"A virtual filesystem driven by userspace syscalls to represent a target
HBA/DEV model on top upstream Linux storage subsystems for fabric
modules using a generic set of configfs struct config_groups to
represent target mode fabric endpoints (WWN+TPG+LUN) designed to allow
each their own set of fabric dependent attributes on top of a generic
kernel infrastructure.

The model is to allow the Linux VFS to handle the TCM core HBA/DEV logic
and both fabric independent and dependent data structure dependencies
between LKMs in order to simplify the conversion of existing and
creation of new target mode fabric code."

Best,

--nab


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
