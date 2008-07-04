Date: Fri, 4 Jul 2008 16:24:03 +0200
From: maximilian attems <max@stro.at>
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
Message-ID: <20080704142403.GD7212@baikonur.stro.at>
References: <1215093175.10393.567.camel@pmac.infradead.org> <20080703173040.GB30506@mit.edu> <1215111362.10393.651.camel@pmac.infradead.org> <20080703.162120.206258339.davem@davemloft.net> <486D6DDB.4010205@infradead.org> <87ej6armez.fsf@basil.nowhere.org> <1215177044.10393.743.camel@pmac.infradead.org> <486E2260.5050503@garzik.org> <1215178035.10393.763.camel@pmac.infradead.org> <20080704141014.GA23215@mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080704141014.GA23215@mit.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Theodore Tso <tytso@mit.edu>, David Woodhouse <dwmw2@infradead.org>, Jeff Garzik <jeff@garzik.org>, Andi Kleen <andi@firstfloor.org>, David Miller <davem@davemloft.net>, hugh@veritas.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, mchan@broadcom.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 04, 2008 at 10:10:14AM -0400, Theodore Tso wrote:
> On Fri, Jul 04, 2008 at 02:27:15PM +0100, David Woodhouse wrote:
> > 
> > That's the way it has been for a _long_ time anyway, for any modern
> > driver which uses request_firmware(). The whole point about modules is
> > _modularity_. Yes, that means that sometimes they depend on _other_
> > modules, or on firmware. 
> > 
> > The scripts which handle that kind of thing have handled inter-module
> > dependencies, and MODULE_FIRMWARE(), for a long time now.
> 
> FYI, at least Ubuntu Hardy's initramfs does not seem to deal with
> firmware for modules correctly.  
> 
> https://bugs.launchpad.net/ubuntu/+source/initramfs-tools/+bug/180544
> 
> And remember, kernel/userspace interfaces are things which are far
> more careful about than kernel ABI interfaces....
> 
> You can flame about Ubuntu being broken (and I predict you will :-),
> but there are a large number of users who do use Ubuntu.  And so
> adding more breakages when it is *known* the distro's aren't moving as
> quickly as you think is reasonable for quote, modern, unquote, drivers
> is something you can flame about, but at the end of the day, *you* are
> the one introducing changes that is causing more breakages.  

yes i'd call them severly broken.
as it is quite easy to pick up the modinfo firmware module output.

their trouble is that they sync initramfs-tools from Debian only
once every 2 years or so.
 
> Userspace interfaces (and this includes things like
> mkinitramfs/mkinitrd, since we made the design decision --- in my
> opinion a very bad decision --- to make initrd/initramfs creation it a
> distro-specific thing instead of somethign where the kernel supplies
> the scripts) by their very nature move much more slowly than things
> which are inside the "shipped by the kernel" boundary.

hpa is working to provide a lot of what is needed in klibc.
it isn't yet there as it misses mdadm, lvm2 and cryptsetup support,
but it is getting much better due to our Debian/Ubuntu exposure.
we added several features to klibc and fixed bugs. similar to the
early opensuse exposure which unfortunately got dropped.

although kinit strived for a very monolithic way that doesn't fit
the modular needs of a distribution. klibc and klibc-utils are
the base of our initramfs.

best regards

-- 
maks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
