Date: Mon, 25 Sep 2000 22:03:01 +0300
From: Matti Aarnio <matti.aarnio@zmailer.org>
Subject: Re: the new VMt [4MB+ blocks]
Message-ID: <20000925220301.Z11669@mea-ext.zmailer.org>
References: <Pine.GSO.4.21.0009251258160.16980-100000@weyl.math.psu.edu> <E13dbhk-0005J0-00@the-village.bc.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <E13dbhk-0005J0-00@the-village.bc.nu>; from alan@lxorguk.ukuu.org.uk on Mon, Sep 25, 2000 at 06:06:11PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 25, 2000 at 06:06:11PM +0100, Alan Cox wrote:
> > > > Stupidity has no limits...
> > > Unfortunately its frequently wired into the hardware to save a few cents on
> > > scatter gather logic.
> > 
> > Since when hardware folks became exempt from the rule above? 128K is
> > almost tolerable, there were requests for 64 _mega_bytes...
> 
> Most cheap ass PCI hardware is built on the basis you can do linear 4Mb 
> allocations. There is a reason for this. You can do that 4Mb allocation on
> NT or Windows 9x

	Sure, but intel processors have this neat 4 MB "super-page"
	feature in the MMU...  (as we all well know)

	Sometimes allocating such monster memory blocks could be supported,
	but it should not be expected to be *fast*.  E.g. if doing it in
	"reliable" way needs possibly moving currently allocated pages
	away from memory to create such a hole(s), so be it..


	Anybody here who can describe those M$ API calls ?
	Are they kernel/DDK-only, or userspace ones, or both ?

/Matti Aarnio
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
