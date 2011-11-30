Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 5A9C36B0047
	for <linux-mm@kvack.org>; Wed, 30 Nov 2011 11:09:21 -0500 (EST)
Date: Wed, 30 Nov 2011 17:09:08 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 2/8] readahead: make default readahead size a kernel
 parameter
Message-ID: <20111130160908.GE4541@quack.suse.cz>
References: <20111121091819.394895091@intel.com>
 <20111121093846.251104145@intel.com>
 <20111121100137.GC5084@infradead.org>
 <20111121113540.GB8895@localhost>
 <20111124222822.GG29519@quack.suse.cz>
 <20111125003633.GP2386@dastard>
 <20111128023922.GA2141@localhost>
 <4ED629CB.401@linux.vnet.ibm.com>
 <20111130132928.GA31589@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111130132928.GA31589@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Ankit Jain <radical@gmail.com>, Rik van Riel <riel@redhat.com>, Nikanth Karthikesan <knikanth@suse.de>, LKML <linux-kernel@vger.kernel.org>, Andi Kleen <andi@firstfloor.org>

On Wed 30-11-11 21:29:28, Wu Fengguang wrote:
> > cat /etc/udev/rules.d/60-readahead.rules
> > # 
> >  
> >  
> > 
> > # Rules to set an increased default max readahead size for s390 disk 
> > devices 
> >  
> > 
> > # This file should be installed in /etc/udev/rules.d 
> >  
> >  
> > 
> > # 
> >  
> > SUBSYSTEM!="block", GOTO="ra_end" 
> > 
> > ACTION!="add", GOTO="ra_end" 
> > 
> > # on device add set initial readahead to 512 (instead of in kernel 128) 
> > 
> > KERNEL=="sd*[!0-9]", ATTR{queue/read_ahead_kb}="512" 
> > 
> > KERNEL=="dasd*[!0-9]", ATTR{queue/read_ahead_kb}="512" 
> 
> So SLES (@s390 and maybe more) is already shipping with 512kb
> readahead size? Good to know this!
  SLES (and openSUSE) since about 2.6.16 times is shipping with 512kb
readahead on everything... With some types of storage it makes a
significant difference.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
