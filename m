Date: Wed, 3 Oct 2007 10:07:03 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Hotplug memory remove
Message-Id: <20071003100703.102033c3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1191345455.6106.10.camel@dyn9047017100.beaverton.ibm.com>
References: <1191253063.29581.7.camel@dyn9047017100.beaverton.ibm.com>
	<20071002011447.7ec1f513.kamezawa.hiroyu@jp.fujitsu.com>
	<1191260987.29581.14.camel@dyn9047017100.beaverton.ibm.com>
	<20071002095257.5b6e2e4c.kamezawa.hiroyu@jp.fujitsu.com>
	<1191345455.6106.10.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 02 Oct 2007 10:17:34 -0700
Badari Pulavarty <pbadari@gmail.com> wrote:

> Kame,
> 
> With little bit of hacking /proc/iomem on ppc64, I got hotplug memory
> remove working. I didn't have to spend lot of time debugging the
> infrastructure you added. Good work !!
> 
I'm very glad to hear that. Thanks!

> Only complaint I have is, the use of /proc/iomem for verification.
> I see few issues.
> 
> 1) On X86-64, /proc/iomem contains all the memory regions, but they
> are all marked IORESOURCE_BUSY. So looking for IORESOURCE_MEM wouldn't
> work and always fails. Is any one working on x86-64 ? 
> 
no one works on x86-64. But I should ask to x86-64 peaple "Why IORESOURCE_BUSY?"
Thank you for pointing out.

> 2) On ppc64, /proc/iomem shows only io-mapped-memory regions. So I
> had to hack it to add all the memory information. I am going to ask
> on ppc64 mailing list on how to do it sanely, but I am afraid that
> they are going to say "all the information is available in the kernel
> data (lmb) structures, parse them - rather than exporting it
> to /proc/iomem". 
> 
> We may have to have arch-specific hooks to verify a memory region :(
> What do you think ?
> 
I think using IORESOURCE_MEM is better.
It is implemtend regardless of memory hotplug. I just reused it.
(I think x86's resouce struct is extened to 64bit for supporting memory info.)

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
