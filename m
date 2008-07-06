Date: Sun, 6 Jul 2008 06:02:30 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
Message-ID: <20080706100230.GA21160@infradead.org>
References: <1215182557.10393.808.camel@pmac.infradead.org> <20080704231322.GA4410@dspnet.fr.eu.org> <s5h4p746am3.wl%tiwai@suse.de> <20080705105317.GA44773@dspnet.fr.eu.org> <486F596C.8050109@firstfloor.org> <20080705120221.GC44773@dspnet.fr.eu.org> <486F6494.8020108@firstfloor.org> <1215260166.10393.816.camel@pmac.infradead.org> <20080705171316.GA3615@infradead.org> <1215291312.3189.88.camel@shinybook.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1215291312.3189.88.camel@shinybook.infradead.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Woodhouse <dwmw2@infradead.org>
Cc: Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Olivier Galibert <galibert@pobox.com>, Takashi Iwai <tiwai@suse.de>, Hannes Reinecke <hare@suse.de>, Theodore Tso <tytso@mit.edu>, Jeff Garzik <jeff@garzik.org>, David Miller <davem@davemloft.net>, hugh@veritas.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, mchan@broadcom.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, Jul 05, 2008 at 09:55:11PM +0100, David Woodhouse wrote:
> > That's unfortunately not true.  There are a lot of drivers that rely
> > on specific firmware versions.
> 
> Do you have examples of such?

The worst examples are aic7xx/aic79xx and the symbios family of drivers
where the firmware / driver interface is entirely defined by the driver.
But as we have opensource firmware for these and build it as part of
the kernel build I suspect you don't want to convert them to external
firmware either.

aic94xx has a very similar firmware to aic7xx/aic79xx but it's only
available as blob.  We've alredy required specific firmware versions
there.

b43 has two totally different firmware major revisions that even require
different drivers.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
