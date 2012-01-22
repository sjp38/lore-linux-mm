Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 347B56B004D
	for <linux-mm@kvack.org>; Sun, 22 Jan 2012 17:12:15 -0500 (EST)
Message-ID: <4F1C897A.3070401@panasas.com>
Date: Mon, 23 Jan 2012 00:11:06 +0200
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] [ATTEND] Future writeback topics
References: <4F1C141C.2050704@panasas.com>  <1327243783.2834.6.camel@dabdike.int.hansenpartnership.com>  <4F1C2D45.4090208@panasas.com> <1327247393.2834.15.camel@dabdike.int.hansenpartnership.com>
In-Reply-To: <1327247393.2834.15.camel@dabdike.int.hansenpartnership.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, "Martin K. Petersen" <martin.petersen@oracle.com>, linux-scsi <linux-scsi@vger.kernel.org>, Dave Chinner <david@fromorbit.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org

On 01/22/2012 05:49 PM, James Bottomley wrote:
> 
> But this topic then becomes adding alignment for non block backed
> filesystems?  I take it you're thinking NFS rather than MTD or MMC?
> 

Sorry to differ. But no this is for most making the IO aligned in the first
place. Block-dev or not. Today VFS has no notion of alignment and IO is
submitted as is with out any alignment considerations.

> For multiple devices, you do a simple cascade ... a bit like dm does
> today ... but unless all the devices are aligned to optimal I/O it never
> really works (and it's not necessarily worth solving ... the idea that
> if you want performance from an array of devices, you match
> characteristics isn't a hugely hard one to get the industry to swallow).
> 

No I'm talking about raid configurations like object raid in exofs/NFS or
raid0/5 in BTRFS and ZFS and such, where there are other larger alignment
structures to consider. Also for large-blocks filesystems/devices who
would like IO aligned on bigger than a page sizes.

Thanks
Boaz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
