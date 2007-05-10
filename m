Date: Thu, 10 May 2007 14:40:04 +0200
From: Adrian Bunk <bunk@stusta.de>
Subject: Re: pcmcia ioctl removal
Message-ID: <20070510124004.GK23574@stusta.de>
References: <20070430162007.ad46e153.akpm@linux-foundation.org> <20070501084623.GB14364@infradead.org> <20070509125415.GA4720@ucw.cz> <20070509130346.GC23574@stusta.de> <1178737912.18573.25.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1178737912.18573.25.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Romano Giannetti <romano@dea.icai.upcomillas.es>
Cc: Pavel Machek <pavel@ucw.cz>, Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-pcmcia@lists.infradead.org
List-ID: <linux-mm.kvack.org>

On Wed, May 09, 2007 at 09:11:52PM +0200, Romano Giannetti wrote:
> On Wed, 2007-05-09 at 15:03 +0200, Adrian Bunk wrote:
> > On Wed, May 09, 2007 at 12:54:16PM +0000, Pavel Machek wrote:
> >  relies on cardmgr anymore.
> > >
> > > I remember needing cardmgr few months ago on sa-1100 arm system. I'm
> > > not sure this is obsolete-enough to kill.
> >
> > Why didn't pcmciautils work?
> 
> I have had a problem until 2.6.20 was out with pcmciautils (it did not
> recognise the second function of multi-functions pcmcia cards that
> needed a firmware .cis file), and the only way to use it was with
> cardmgr, way after Nov 2005 :-).
> 
> Now it is solved (modulo that sometime the pcmcia modem is ttyS1,
> sometime ttyS2, but that's another history --- and probably my fault).
> But I wonder if similar problems are hidden away... what about put the
> ioctls under a normally-disabled option and let a kernel out with it?

It already prints a runtime warning to the user since 2005.
And people won't notice a changed default when using "make oldconfig".

Are there any known known regressions left?
Otherwise, the best way for getting problem reports for pcmciautils is 
to remove the ioctl (that's an experience from similar cases in other 
parts of the kernel)...

> Romano

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
