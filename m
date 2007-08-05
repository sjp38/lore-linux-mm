Date: Sun, 5 Aug 2007 21:32:31 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 00/23] per device dirty throttling -v8
Message-ID: <20070805193231.GA21928@elte.hu>
References: <20070804163733.GA31001@elte.hu> <alpine.LFD.0.999.0708041030040.5037@woody.linux-foundation.org> <46B4C0A8.1000902@garzik.org> <20070805102021.GA4246@unthought.net> <46B5A996.5060006@garzik.org> <20070805105850.GC4246@unthought.net> <20070805124648.GA21173@elte.hu> <alpine.LFD.0.999.0708050944470.5037@woody.linux-foundation.org> <20070805190928.GA17433@elte.hu> <20070805202930.4ce62542@the-village.bc.nu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070805202930.4ce62542@the-village.bc.nu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Jakob Oestergaard <jakob@unthought.net>, Jeff Garzik <jeff@garzik.org>, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, david@lang.hm
List-ID: <linux-mm.kvack.org>

* Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:

> > also add the CONFIG_DEFAULT_RELATIME kernel option, which makes 
> > "norelatime" the default for all mounts without an extra kernel boot 
> > option.
> 
> Should be a mount option.

it is already a mount option too.

> > +	relatime        [FS] default to enabled relatime updates on all
> > +			filesystems.
> > +
> > +	relatime=       [FS] default to enabled/disabled relatime updates on
> > +			all filesystems.
> > +
> 
> Double patch

no - it was not a double patch, i made all the common variants valid 
boot options: "relatime", "relatime=0/1", "norelatime" and 
"norelatime=0/1". Anyway, this is mooth, in the latest (v2) version 
there's only a single boot parameter.

> > +config DEFAULT_RELATIME
> > +	bool "Mount all filesystems with relatime by default"
> > +	default y
> 
> Changes behaviour so probably should default n. Better yet it should 
> be the mount option so its flexible and strongly encouraged for 
> vendors.

relatime is a mount option already. And distros can disable it if they 
want. (they are conscious about their kernel config selections anyway.)

> > +0
> > +#endif
> > +;
> 
> This ifdef mess would go away for a mount option

i fixed that in v2.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
