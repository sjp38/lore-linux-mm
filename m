Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id B09AF6B01E3
	for <linux-mm@kvack.org>; Thu, 13 May 2010 15:38:12 -0400 (EDT)
Date: Thu, 13 May 2010 12:21:33 -0700
From: Greg KH <gregkh@suse.de>
Subject: Re: [RFC, 6/7] NUMA hotplug emulator
Message-ID: <20100513192133.GA17888@suse.de>
References: <20100513120016.GG2169@shaohui>
 <20100513165603.GC25212@suse.de>
 <1273773737.13285.7771.camel@nimitz>
 <20100513181539.GA26597@suse.de>
 <1273776578.13285.7820.camel@nimitz>
 <20100513185844.GA5959@suse.de>
 <1273778203.13285.7851.camel@nimitz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1273778203.13285.7851.camel@nimitz>
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Andi Kleen <ak@linux.intel.com>, Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, shaohui.zheng@linux.intel.com
List-ID: <linux-mm.kvack.org>

On Thu, May 13, 2010 at 12:16:43PM -0700, Dave Hansen wrote:
> On Thu, 2010-05-13 at 11:58 -0700, Greg KH wrote:
> > > That's probably a really good point, especially since configfs didn't
> > > even exist when we made this 'probe' file thingy.  It never was a great
> > > fit for sysfs anyway.
> > 
> > Really?  configfs was added in 2.6.16, when was this probe file added?
> 
> $ git name-rev 3947be19
> 3947be19 tags/v2.6.15-rc1~728^2~12

Ah, so close, off by 3 months :)

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
