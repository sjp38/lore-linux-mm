Date: Fri, 5 Oct 2001 02:55:42 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: __alloc_pages: 0-order allocation failed in 2.4.10
Message-ID: <20011005025542.F724@athlon.random>
References: <5.0.0.25.2.20011004181232.00a459b0@cic-mail.lanl.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5.0.0.25.2.20011004181232.00a459b0@cic-mail.lanl.gov>; from mariella@lanl.gov on Thu, Oct 04, 2001 at 06:13:39PM -0600
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mariella Di Giacomo <mariella@lanl.gov>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello Mariella,

On Thu, Oct 04, 2001 at 06:13:39PM -0600, Mariella Di Giacomo wrote:
> Hello,
> 
> I'm running 2.4.10 on a SMP box with 4G of memory; I've  installed
> the patch to let a process use up to 3.5 GB and I set highmem 4G.
> I was using NFS to get remote files and copy them (using cpio) to the
> local filesystem (SCSI drive).
> After a while I started getting the following errors and the processes died.

Can you reproduce on top of 2.4.11pre3aa1?

	ftp://ftp.us.kernel.org/pub/linux/kernel/people/andrea/kernels/v2.4/2.4.11pre3aa1.bz2

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
