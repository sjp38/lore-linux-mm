Received: from hera.ecs.csus.edu (hera.ecs.csus.edu [130.86.71.150])
	by kvack.org (8.8.7/8.8.7) with ESMTP id SAA08437
	for <linux-mm@kvack.org>; Mon, 3 Aug 1998 18:59:08 -0400
Date: Mon, 3 Aug 1998 15:58:31 -0700 (PDT)
From: "Jon M. Taylor" <taylorj@ecs.csus.edu>
Subject: Re: S3trio framebuffer on Intel?
In-Reply-To: <Pine.LNX.3.96.980803190939.3185A-100000@mirkwood.dummy.home>
Message-ID: <Pine.HPP.3.91.980803153234.23083G-100000@gaia.ecs.csus.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: Craig Schlenter <craig@is.co.za>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 3 Aug 1998, Rik van Riel wrote:

> On Mon, 3 Aug 1998, Craig Schlenter wrote:
> > On Sun, 2 Aug 1998, Rik van Riel wrote:
> > 
> > > It sure would be cool to have native S3trio support
> > > from the kernel :)
> > 
> > Agreed. I asked this a week or two back. It seems as if the s3 stuff in
> > the kernel is ppc specific (but maybe someone can tune it a little) and
> 
> According to Geert, the S3triofb driver needs the video
> mode setup to by some other code;
> According to Jon, the KGI S3 driver works without prior
> setup stuff.

	It can also run in MMIO mode for multiheading and supports S3 fast
text mode.

> Maybe the KGI S3 setup code could be ported into the
> S3triofb driver?    [preferably by someone with both
> intimate knowledge of the video code and free time]
> 
> After that, the S3trio driver might still need some
> endianness porting, but possibly that's just a minor
> nuisance instead of real trouble.

	Yes, and after all that work you will still have a Trio driver
that only supports 8 and 16(?) bpp modes and a few fixed resolutions and
mode timings.  On the other hand, the kgicon Trio driver supports all bit
depths from 1bpp to 32bpp, infinitely variable mode timings, infinitely
variable resolutions, MMIO and multiheading, and has real monitor drivers. 
kgicon supports YPAN, YWRAP, splitline, modesetting via fbset and can be
loaded as a module with the initial mode params passed in as module
parameters.  

	It seems like people are willing to expend an awful lot of energy
to avoid using kgicon, but I don't see why.  kgicon is more compliant to
the fbcon spec than a lot of the existing fbcon drivers are.  The only
thing it lacks is kernel integration - everything is built as modules
right now.  But that should be easy to implement, and loading a module and
using con2fbmap to migrate the consoles to the new device is not that
tough.  I have watched with bemusement the ordeals that people have had to
go through to get vesafb to work, and when they finally do they are
limited to one fixed mode with no YPAN/YWRAP or scrollback. I can just
insert a module and have all the graphical consoles I need, any way I want
them, and since they support YPAN/YWRAP they are FAST.

	If you guys want to continue to beat your brains out in this
fashion, be my guest.  I just want to make sure you know that there is a
superior solution out there, and it works NOW.

Jon

---
'Cloning and the reprogramming of DNA is the first serious step in 
becoming one with God.'
	- Scientist G. Richard Seed

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
