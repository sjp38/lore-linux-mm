Date: Fri, 4 Jul 2008 10:10:14 -0400
From: Theodore Tso <tytso@mit.edu>
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
Message-ID: <20080704141014.GA23215@mit.edu>
References: <1215093175.10393.567.camel@pmac.infradead.org> <20080703173040.GB30506@mit.edu> <1215111362.10393.651.camel@pmac.infradead.org> <20080703.162120.206258339.davem@davemloft.net> <486D6DDB.4010205@infradead.org> <87ej6armez.fsf@basil.nowhere.org> <1215177044.10393.743.camel@pmac.infradead.org> <486E2260.5050503@garzik.org> <1215178035.10393.763.camel@pmac.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1215178035.10393.763.camel@pmac.infradead.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Woodhouse <dwmw2@infradead.org>
Cc: Jeff Garzik <jeff@garzik.org>, Andi Kleen <andi@firstfloor.org>, David Miller <davem@davemloft.net>, hugh@veritas.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, mchan@broadcom.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 04, 2008 at 02:27:15PM +0100, David Woodhouse wrote:
> 
> That's the way it has been for a _long_ time anyway, for any modern
> driver which uses request_firmware(). The whole point about modules is
> _modularity_. Yes, that means that sometimes they depend on _other_
> modules, or on firmware. 
> 
> The scripts which handle that kind of thing have handled inter-module
> dependencies, and MODULE_FIRMWARE(), for a long time now.

FYI, at least Ubuntu Hardy's initramfs does not seem to deal with
firmware for modules correctly.  

https://bugs.launchpad.net/ubuntu/+source/initramfs-tools/+bug/180544

And remember, kernel/userspace interfaces are things which are far
more careful about than kernel ABI interfaces....

You can flame about Ubuntu being broken (and I predict you will :-),
but there are a large number of users who do use Ubuntu.  And so
adding more breakages when it is *known* the distro's aren't moving as
quickly as you think is reasonable for quote, modern, unquote, drivers
is something you can flame about, but at the end of the day, *you* are
the one introducing changes that is causing more breakages.  

Userspace interfaces (and this includes things like
mkinitramfs/mkinitrd, since we made the design decision --- in my
opinion a very bad decision --- to make initrd/initramfs creation it a
distro-specific thing instead of somethign where the kernel supplies
the scripts) by their very nature move much more slowly than things
which are inside the "shipped by the kernel" boundary.

And sometimes people like to take a RHEL4 or RHEL5 (or Ubuntu Hardy)
kernel and compile and build a much newer kernel from kernel.org, and
it is *highly* unfortunate when this breaks.  After all, for people
who care to test our kernel.org kernels, we want to encourage them,
yes?  More testers of kernel.org testers is something which I've heard
akpm claim is a good thing....

I do think your idea of including "make firmware_install" into "make
modules_install" does make a lot of sense, because it will reduce the
number of breakages.  It won't eliminate them, but it will reduce them.

Regards,

       	  	      	       		       - Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
