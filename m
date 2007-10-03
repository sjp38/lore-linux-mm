Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e32.co.us.ibm.com (8.12.11.20060308/8.13.8) with ESMTP id l93EOYfS010425
	for <linux-mm@kvack.org>; Wed, 3 Oct 2007 10:24:34 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l93FWupT474542
	for <linux-mm@kvack.org>; Wed, 3 Oct 2007 09:32:57 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l93FWt79010739
	for <linux-mm@kvack.org>; Wed, 3 Oct 2007 09:32:56 -0600
Subject: Re: [RFC] PPC64 Exporting memory information through /proc/iomem
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <20071003101954.52308f22.kamezawa.hiroyu@jp.fujitsu.com>
References: <1191346196.6106.20.camel@dyn9047017100.beaverton.ibm.com>
	 <18178.52359.953289.638736@cargo.ozlabs.ibm.com>
	 <1191366653.6106.68.camel@dyn9047017100.beaverton.ibm.com>
	 <20071003101954.52308f22.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain
Date: Wed, 03 Oct 2007 08:35:35 -0700
Message-Id: <1191425735.6106.76.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Paul Mackerras <paulus@samba.org>, linuxppc-dev@ozlabs.org, linux-mm <linux-mm@kvack.org>, anton@au1.ibm.com
List-ID: <linux-mm.kvack.org>

On Wed, 2007-10-03 at 10:19 +0900, KAMEZAWA Hiroyuki wrote:
> On Tue, 02 Oct 2007 16:10:53 -0700
> Badari Pulavarty <pbadari@us.ibm.com> wrote:
> > > > Otherwise, we need to add arch-specific hooks in hotplug-remove
> > > > code to be able to do this.
> > > 
> > > Isn't it just a matter of abstracting the test for a valid range of
> > > memory?  If it's really hard to abstract that, then I guess we can put
> > > RAM in iomem_resource, but I'd rather not.
> > > 
> > 
> > Sure. I will work on it and see how ugly it looks.
> > 
> > KAME, are you okay with abstracting the find_next_system_ram() and
> > let arch provide whatever implementation they want ? (since current
> > code doesn't work for x86-64 also ?).
> > 
> Hmm, registering /proc/iomem is complicated ?

Its not complicated. Like Paul mentioned, its part of user/kernel API
which he is not prefering to break (if possible) + /proc/iomem seems
like a weird place to export conventional memory.

>  If too complicated, adding config
> like
> CONFIG_ARCH_SUPPORT_IORESOURCE_RAM or something can do good work.
> you can define your own "check_pages_isolated" (you can rename this to
> arch_check_apges_isolated().)

I was thinking more in the lines of 

CONFIG_ARCH_HAS_VALID_MEMORY_RANGE. Then define own
find_next_system_ram() (rename to is_valid_memory_range()) - which
checks the given range is a valid memory range for memory-remove
or not. What do you think ?

Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
