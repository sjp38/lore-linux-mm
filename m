Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 8D9A26B01AF
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 12:13:45 -0400 (EDT)
Message-ID: <4C1A49B3.4020903@panasas.com>
Date: Thu, 17 Jun 2010 12:13:39 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
Subject: Re: Current topics for LSF10/MM Summit 8-9 August in Boston
References: <1276721459.2847.399.camel@mulgrave.site>	 <20100617160048.GA11689@schmichrtp.mainz.de.ibm.com> <1276790850.7398.8.camel@mulgrave.site>
In-Reply-To: <1276790850.7398.8.camel@mulgrave.site>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Christof Schmitt <christof.schmitt@de.ibm.com>, linux-scsi@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, lsf10-pc@lists.linuxfoundation.org
List-ID: <linux-mm.kvack.org>

On 06/17/2010 12:07 PM, James Bottomley wrote:
> On Thu, 2010-06-17 at 18:00 +0200, Christof Schmitt wrote:
>> On Wed, Jun 16, 2010 at 03:50:59PM -0500, James Bottomley wrote:
>>> Given that we're under two months out, I thought it would be time to
>>> post a summary of the topics we've collected so far (Nick will post the
>>> MM summit ones later).  Look this over, and if there's anything missing,
>>> propose it ... or if you have cross Storage/FS/MM topics, post them too.
>>>
>>> Oh, and since we're not the most organised bunch, if you posted a topic
>>> and don't see it in the list, please resend ... we probably lost it in
>>> an email shuffle.
>>>
>>> Current Filesystem Topics:
>>>
>>> Alex Elder	Upstream maintainer for XFS, general discussion on FS/IO
>>> Aneesh Kumar	Rich-acl patches which work better with NFSv4 acl and CIFS acl
>>> Anshul Madan	reflink for NFS
>>> Chuck Lever	NFS/IPV6 and NFS O_DIRECT, Wu's read-ahead work, vitro perf tools
>>> Eric Sandeen	Advances in testing, TRIM/DISCARD/Alignment, writeback sanity
>>> James Lentini	reflink for NFS
>>> Jan Kara	Discuss/drive sanity review of writeback and general ext*/jbd 
>>> Michael Rubin	Writeback scaling
>>> Sage Weil	Statlite, generic interface for describing file striping for distributed FS, VFS scalability
>>> Al Viro	Sorting out d_revalidate and other dcache issues
>>> Coly Li		directory/large file scalability
>>> Sorin Faibish	Cache writeback discussion
>>>
>>> Current Storage Topics:
>>>
>>> Eric Seppanen	Next generation SSDs, performance implications on Linux I/O
>>> Boaz Harrosh	PNFS performance considerations, bio_list based/async raidN for generic use; stable pages for I/O
>>> FUJITA Tomonori	SCSI target mode, iSCSI, block layer SG (bsg), sg, IOMMU, DMA issues
>>> Hannes Reinecke	libfc/multipath/error handing
>>> James Smart	FCOE proposal for rework of the FC sysfs tree, work with Hannes on other transport/SCSI subsystem topics
>>> Jeff Moyer	IO scheduler
>>> Joel Becker	SAN management plugin
>>> Martin Petersen	Updates on DIF/DIX, TRIM/DISCARD/UNMAP, generic support for WRITE_SAME
>>>
>>> Plus some MM summit ones which Nick will summarise.
>> [...]
>>
>> What about the topic "Stable pages while IO"?
>> http://www.spinics.net/lists/linux-scsi/msg44074.html
>>
>> Was it lost during the e-mail shuffle or will it be part of the MM topics?
> 
> It's actually listed under 'dma issues' ... but there's really been no
> satisfactory resolution or discussion of how one might be achieved.
> Most filesystems rely on modifications to in-flight pages for efficiency
> and copying every fs I/O page would be horrendous both for performance
> and memory consumption.  Nor has there really been an indication that
> it's a serious issue.  The two sufferers are DIF and iSCSI checksum.
> The latter generates the checksum late enough that it can just discard
> incorrect pages ... the former might need simply to turn off DIF for
> everything other than DIRECT IO.

What about raid and mirror that do copy the complete IO load
just because of that? They gave up long ago but wouldn't they
gain if that was revisited? (And so would DIF/checksum)

> 
> James
> 

Boaz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
