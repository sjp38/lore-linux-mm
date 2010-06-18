Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 381D46B01CA
	for <linux-mm@kvack.org>; Fri, 18 Jun 2010 08:18:40 -0400 (EDT)
Date: Fri, 18 Jun 2010 08:18:34 -0400
Subject: Re: [Lsf10-pc] Current topics for LSF10/MM Summit 8-9 August in
	Boston
Message-ID: <20100618121833.GB10887@fieldses.org>
References: <1276721459.2847.399.camel@mulgrave.site> <20100617160048.GA11689@schmichrtp.mainz.de.ibm.com> <1276790850.7398.8.camel@mulgrave.site>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1276790850.7398.8.camel@mulgrave.site>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: owner-linux-mm@kvack.org
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Christof Schmitt <christof.schmitt@de.ibm.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, lsf10-pc@lists.linuxfoundation.org, linux-scsi@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 17, 2010 at 11:07:30AM -0500, James Bottomley wrote:
> It's actually listed under 'dma issues' ... but there's really been no
> satisfactory resolution or discussion of how one might be achieved.
> Most filesystems rely on modifications to in-flight pages for efficiency
> and copying every fs I/O page would be horrendous both for performance
> and memory consumption.  Nor has there really been an indication that
> it's a serious issue.  The two sufferers are DIF and iSCSI checksum.

And, again, NFS (both client (on writes) and server (on reads)), when
using sec=krb5i.  Haven't tried to reproduce the problem, but I believe
it would result in spurious IO errors.

--b.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
