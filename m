Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id C38096B008A
	for <linux-mm@kvack.org>; Thu, 24 Nov 2011 17:28:29 -0500 (EST)
Date: Thu, 24 Nov 2011 23:28:22 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 2/8] readahead: make default readahead size a kernel
 parameter
Message-ID: <20111124222822.GG29519@quack.suse.cz>
References: <20111121091819.394895091@intel.com>
 <20111121093846.251104145@intel.com>
 <20111121100137.GC5084@infradead.org>
 <20111121113540.GB8895@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111121113540.GB8895@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Ankit Jain <radical@gmail.com>, Dave Chinner <david@fromorbit.com>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Nikanth Karthikesan <knikanth@suse.de>, LKML <linux-kernel@vger.kernel.org>, Andi Kleen <andi@firstfloor.org>

On Mon 21-11-11 19:35:40, Wu Fengguang wrote:
> On Mon, Nov 21, 2011 at 06:01:37PM +0800, Christoph Hellwig wrote:
> > On Mon, Nov 21, 2011 at 05:18:21PM +0800, Wu Fengguang wrote:
> > > From: Nikanth Karthikesan <knikanth@suse.de>
> > > 
> > > Add new kernel parameter "readahead=", which allows user to override
> > > the static VM_MAX_READAHEAD=128kb.
> > 
> > Is a boot-time paramter really such a good idea?  I would at least
> 
> It's most convenient to set at boot time, because the default size
> will be used to initialize all the block devices.
> 
> > make it a sysctl so that it's run-time controllable, including
> > beeing able to set it from initscripts.
> 
> Once boot up, it's more natural to set the size one by one, for
> example
> 
>         blockdev --setra 1024 /dev/sda2
> or
>         echo 512 > /sys/block/sda/queue/read_ahead_kb
> 
> And you still have the chance to modify the global default, but the
> change will only be inherited by newly created devices thereafter:
> 
>         echo 512 > /sys/devices/virtual/bdi/default/read_ahead_kb
> 
> The above command is very suitable for use in initscripts.  However
> there are no natural way to do sysctl as there is no such a global
> value.
  Well, you can always have an udev rule to set read_ahead_kb to whatever
you want. In some respect that looks like a nicer solution to me...

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
