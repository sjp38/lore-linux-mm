Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 3E9266B01EC
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 10:45:23 -0400 (EDT)
Date: Mon, 21 Jun 2010 16:45:20 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [Lsf10-pc] Current MM topics for LSF10/MM Summit 8-9 August in
 Boston
Message-ID: <20100621144520.GB5787@random.random>
References: <1276721459.2847.399.camel@mulgrave.site>
 <20100621120526.GA31679@laptop>
 <20100621131608.GW5787@random.random>
 <20100621132238.GK4689@redhat.com>
 <20100621140939.GY5787@random.random>
 <20100621141855.GN4689@redhat.com>
 <20100621142952.GZ5787@random.random>
 <4C1F77CD.40509@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4C1F77CD.40509@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Gleb Natapov <gleb@redhat.com>, Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, lsf10-pc@lists.linuxfoundation.org, linux-scsi@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 21, 2010 at 05:31:41PM +0300, Avi Kivity wrote:
> On 06/21/2010 05:29 PM, Andrea Arcangeli wrote:
> > On Mon, Jun 21, 2010 at 05:18:56PM +0300, Gleb Natapov wrote:
> >    
> >> Avi did the fix. We discussed using MADV_DONTFORK for that, but calling
> >> madvise() from kernel deemed to be messy.
> >>      
> > Agree that calling madvise looks messy. It's possible to set
> > VM_DONTCOPY under mmap_sem write mode and it'll work as well.
> >    
> 
> But we aren't guaranteed to get our own vma, yes?

Correct, one would need to call split_vma like madvise_behavior does
before setting the flag. For sure current fix is simpler ;).

> Note kvm shouldn't be calling do_mmap() in any case.  I let that in 
> because it was simple and because we had a userspace interface relying 
> on that, but that's no longer the case, so I'll make that page kernel owned.

Agree ;).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
