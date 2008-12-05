Date: Fri, 5 Dec 2008 10:44:48 +0100
From: "Hans J. Koch" <hjk@linutronix.de>
Subject: Re: [PATCH 1/1] Userspace I/O (UIO): Add support for userspace DMA
Message-ID: <20081205094447.GA3081@local>
References: <43FC624C55D8C746A914570B66D642610367F29B@cos-us-mb03.cos.agilent.com> <1228379942.5092.14.camel@twins> <20081204180809.GB3079@local> <1228461060.18899.8.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1228461060.18899.8.camel@twins>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: "Hans J. Koch" <hjk@linutronix.de>, edward_estabrook@agilent.com, linux-kernel@vger.kernel.org, gregkh@suse.de, edward.estabrook@gmail.com, hugh <hugh@veritas.com>, linux-mm <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>
List-ID: <linux-mm.kvack.org>

On Fri, Dec 05, 2008 at 08:10:59AM +0100, Peter Zijlstra wrote:
> > I don't like to have a separate device for DMA memory. It would completely
> > break the current concept of userspace drivers if you had to get normal
> > memory from one device and DMA memory from another. Note that one driver
> > can have both.
> 
> How would that break anything, the one driver can simply open both
> files.

I agree there's not much breakage, but it's a difference in handling things.
People who wrote libraries that generically find mappable memory of a UIO
device need to change their handling.

> 
> > But I agree that it's confusing if the physical address is stored somewhere
> > in the mapped memory. That should simply be omitted, we have that information
> > in sysfs anyway - like for any other memory mappings. But I guess we need
> > some kind of "type" or "flags" attribute for the mappings so that userspace
> > can find out if a mapping is DMA capable or not.
> 
> We have that, different file.
> 
> I'll NAK any attempt that rapes the mmap interface like proposed - that
> is just not an option.

Well, UIO already rapes the mmap interface by using the "offset" parameter to
pass in the number of the mapping.
But I'll NAK the current concept, too. It's a UIO kernel driver's task to tell
userspace which memory a device has to offer. The UIO core prevents userspace
as much as possible from mapping anything different. And it should stay that
way.

Thanks,
Hans

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
