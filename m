Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id D46BF6006F7
	for <linux-mm@kvack.org>; Thu,  1 Jul 2010 14:26:46 -0400 (EDT)
Subject: Re: Current MM topics for LSF10/MM Summit 8-9 August in Boston
From: Larry Woodman <lwoodman@redhat.com>
In-Reply-To: <20100621120526.GA31679@laptop>
References: <1276721459.2847.399.camel@mulgrave.site>
	 <20100621120526.GA31679@laptop>
Content-Type: text/plain
Date: Thu, 01 Jul 2010 14:30:37 -0400
Message-Id: <1278009037.3223.167.camel@dhcp-100-19-198.bos.redhat.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: linux-mm@kvack.org, lsf10-pc@lists.linuxfoundation.org
List-ID: <linux-mm.kvack.org>

On Mon, 2010-06-21 at 22:05 +1000, Nick Piggin wrote:
> Apologies for the delay, there haven't been a lot of explicit proposals
> for topics, but I think there is a lot to talk about, so I would like to
> hear more ideas but I have suggested a few of my own.

I'd like to attend if possible.

Larry Woodman

> 
> Rik van Riel		Memory management under virtualization (with KVM)
> Andrea Arcangeli	Transparent hugepages
> KOSAKI Motohiro		get_user_pages vs COW problem
> Boaz Harrosh		Stable page contents under writeback
> Michael Rubin, Sorin Faibish, Jan Kara	Writeback issues (several subtopics)
> 
> I propose some other possible topics for agenda
> - Zone aware slab reclaim (eg. dentry, inode)
> - mmap_sem scalability, again
> - Page allocator scalability
> - OOM killer work
> - Direct reclaim, direct writeback problems
> 
> Thanks,
> Nick
> 
> On Wed, Jun 16, 2010 at 03:50:59PM -0500, James Bottomley wrote:
> > Given that we're under two months out, I thought it would be time to
> > post a summary of the topics we've collected so far (Nick will post the
> > MM summit ones later).  Look this over, and if there's anything missing,
> > propose it ... or if you have cross Storage/FS/MM topics, post them too.
> > 
> > Oh, and since we're not the most organised bunch, if you posted a topic
> > and don't see it in the list, please resend ... we probably lost it in
> > an email shuffle.
> > 
> > Current Filesystem Topics:
> > 
> > Alex Elder	Upstream maintainer for XFS, general discussion on FS/IO
> > Aneesh Kumar	Rich-acl patches which work better with NFSv4 acl and CIFS acl
> > Anshul Madan	reflink for NFS
> > Chuck Lever	NFS/IPV6 and NFS O_DIRECT, Wu's read-ahead work, vitro perf tools
> > Eric Sandeen	Advances in testing, TRIM/DISCARD/Alignment, writeback sanity
> > James Lentini	reflink for NFS
> > Jan Kara	Discuss/drive sanity review of writeback and general ext*/jbd 
> > Michael Rubin	Writeback scaling
> > Sage Weil	Statlite, generic interface for describing file striping for distributed FS, VFS scalability
> > Al Viro	Sorting out d_revalidate and other dcache issues
> > Coly Li		directory/large file scalability
> > Sorin Faibish	Cache writeback discussion
> > 
> > Current Storage Topics:
> > 
> > Eric Seppanen	Next generation SSDs, performance implications on Linux I/O
> > Boaz Harrosh	PNFS performance considerations, bio_list based/async raidN for generic use; stable pages for I/O
> > FUJITA Tomonori	SCSI target mode, iSCSI, block layer SG (bsg), sg, IOMMU, DMA issues
> > Hannes Reinecke	libfc/multipath/error handing
> > James Smart	FCOE proposal for rework of the FC sysfs tree, work with Hannes on other transport/SCSI subsystem topics
> > Jeff Moyer	IO scheduler
> > Joel Becker	SAN management plugin
> > Martin Petersen	Updates on DIF/DIX, TRIM/DISCARD/UNMAP, generic support for WRITE_SAME
> > 
> > Plus some MM summit ones which Nick will summarise.
> > 
> > For the benefit of those who've forgotten here's the original Call for
> > topics and attendees:
> > 
> > This year we'll hold the Linux Storage and Filesystems summit jointly
> > with the VM summit on the two days before LinuxCon in Boston (that's
> > Sunday and Monday) at the Renaissance Hotel:
> > 
> > http://events.linuxfoundation.org/events/linuxcon
> > 
> > We're planning to hold some sessions jointly and split into three tracks
> > (Filesystems, Storage and VM) for others, so we're encouraging proposals
> > for discussion that cover areas relevant to all three groups as well as
> > more specific technical topics.
> > 
> > Suggestions for agenda topics should be sent to
> > 
> > lsf10-pc@lists.linuxfoundation.org
> > 
> > and optionally cc the Linux list which would be most interested in it:
> > 
> > SCSI: linux-scsi@vger.kernel.org
> > FS: linux-fsdevel@vger.kernel.org (plus relevant fs specific list)
> > MM: linux-mm@kvack.org
> > 
> > Please tag your subject with [LSF/VM TOPIC] so those of us who're not
> > very organised can find them easily in our inboxes.  The agenda topics
> > and attendees will be selected by the programme committee, but the final
> > agenda will be by formed by consensus of the attendees on the day.
> > 
> > We'll try to cap attendance at around 20 per track to facilitate
> > discussions although the final numbers will depend on the room sizes
> > at the venue.
> > 
> > Requests to attend should be sent to:
> > 
> > lsf10-pc@lists.linuxfoundation.org
> > 
> > please summarise what you'll bring to the meeting, and what you'd like
> > to discuss.  please also tag your email with [ATTEND] so there's less
> > chance of it getting lost in the large mail pile.
> > 
> > Presentations are allowed to guide discussion, but are strongly
> > discouraged.  There will be no recording or audio bridge, however
> > written minutes will be published as in previous years:
> > 
> > 2009:
> > http://lwn.net/Articles/327601/
> > http://lwn.net/Articles/327740/
> > http://lwn.net/Articles/328347/
> > 
> > Prior years:
> > http://www.usenix.org/events/lsf08/tech/lsf08sums.pdf
> > http://www.usenix.org/publications/login/2007-06/openpdfs/lsf07sums.pdf
> > 
> > If you have feedback on last year's meeting that we can use to improve
> > this year's, please also send that to:
> > 
> > lsf10-pc@lists.linuxfoundation.org
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
