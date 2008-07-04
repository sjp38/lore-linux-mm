Message-ID: <486D783B.6040904@infradead.org>
Date: Fri, 04 Jul 2008 02:09:15 +0100
From: David Woodhouse <dwmw2@infradead.org>
MIME-Version: 1.0
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
References: <1215093175.10393.567.camel@pmac.infradead.org> <20080703173040.GB30506@mit.edu> <1215111362.10393.651.camel@pmac.infradead.org> <20080703.162120.206258339.davem@davemloft.net> <20080704001855.GJ30506@mit.edu>
In-Reply-To: <20080704001855.GJ30506@mit.edu>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Theodore Tso <tytso@mit.edu>, David Miller <davem@davemloft.net>, dwmw2@infradead.org, jeff@garzik.org, hugh@veritas.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, mchan@broadcom.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Theodore Tso wrote:
> On Thu, Jul 03, 2008 at 04:21:20PM -0700, David Miller wrote:
>> You want to choose a default based upon your legal agenda.
> 
> Yep, legal agenda.  As I suspected, licensing religious fundamentalism.  :-)

You are mistaken, and you're responding some words that someone _else_ 
put in my mouth.

> The staged approach means that if you really want to do this ASAP,
> then start assembling the firmware tarball *now*,

That's easy enough. We can automatically generate a tree _from_ Linus' 
tree, with a scripted transform so that it includes only the firmware 
files (much like the kernel-headers tree automatically follows each 
commit in Linus' tree, but includes only the exported headers).

And there are some hardware manufacturers who are willing to have their 
firmware included in such a firmware tarball, but who will _not_ give 
their permission to have it included in the Linux kernel because of the 
legal concerns you're so dismissive of. But that's OK -- we can pull 
from the automatically generated tree into a 'real' linux-firmware.git 
tree, which includes those extra firmware files.

But there's no need to do it _now_. It can wait until the basic stuff is 
in Linus' tree and it can automatically derive from that. There's no 
particular rush, is there?

> and for a while (read: at least 9-18 months) we can distribute firmware
 > both in the kernel source tarball as well as separately

That makes a certain amount of sense.

> in the licensing-religion-firmware tarball. 

Please don't be gratuitously offensive, Ted. It's not polite, and it's 
not a particularly good debating technique either. I expect better from you.

> See if you can get distros willing to ship it by default in most
> user's  systems, and give people plenty of time to understand that we
 > are trying to decouple firmware from the kernel sources.

The distros are certainly willing (and keen) to do it. The Fedora 
Engineering Steering Committee has already stated that it wants to do 
so, and the specfile changes to spit out a 'kernel-firmware' sub-package 
with the kernel build are ready to go right now.

Fedora already modifies tarballs, for example 'openssh-5.0p1-noacss'. I 
think it's quite likely they'd end up using a 'linux-2.6.27-nofirmware' 
tarball too, and build the firmware package from the separate tree.

Some other distributions have been doing that kind of thing _already_, 
even when it meant just ripping out certain drivers completely. That 
seems excessive to me; I prefer not to actually _break_ anything.

> If we need to institute better versioning regimes between the drivers
 > and firmware release levels, that will also give people a chance to
 > get that all right.  Then 6-9 months later, we can turn the default
> to 'no', and then maybe another 6-9 months after that, we can talk 
 > about removing the firmware modules.
> But it seems to me that you are skipping a few steps by arguing that
> the default should be changed here-and-now.

I disagree that the _default_ is such an issue -- largely because the 
normal case for modern drivers is not to include the firmware _anyway_, 
and the tools like 'mkinitrd' already cope with it just fine.

But I've changed the default to 'y' now, as I already said.

-- 
dwmw2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
