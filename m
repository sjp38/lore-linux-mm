Date: Tue, 8 Jul 2003 13:01:22 +0200
From: Petr Vandrovec <vandrove@vc.cvut.cz>
Subject: Re: 2.5.74-mm2 + nvidia (and others)
Message-ID: <20030708110122.GA10756@vana.vc.cvut.cz>
References: <1057590519.12447.6.camel@sm-wks1.lan.irkk.nu> <1057647818.5489.385.camel@workshop.saharacpt.lan> <20030708072604.GF15452@holomorphy.com> <200307081051.41683.schlicht@uni-mannheim.de> <20030708085558.GG15452@holomorphy.com> <1057657046.1819.11.camel@mufasa.ds.co.ug>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1057657046.1819.11.camel@mufasa.ds.co.ug>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Peter C. Ndikuwera" <pndiku@dsmagic.com>
Cc: William Lee Irwin III <wli@holomorphy.com>, Thomas Schlichter <schlicht@uni-mannheim.de>, Martin Schlemmer <azarah@gentoo.org>, Andrew Morton <akpm@osdl.org>, smiler@lanil.mine.nu, KML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 08, 2003 at 12:37:26PM +0300, Peter C. Ndikuwera wrote:
> The VMware patches are ...
> 
> ftp://platan.vc.cvut.cz/pub/vmware/vmware-any-any-updateXX.tar.gz

vmware-any-any-update35.tar.gz should work on 2.5.74-mm2 too.
But it is not tested, I have enough troubles with 2.5.74 without mm patches...

> > On Tue, Jul 08, 2003 at 10:51:39AM +0200, Thomas Schlichter wrote:
> > > Btw, what do you think about the idea of exporting the follow_pages()
> > > function from mm/memory.c to kernel modules? So this could be used
> > > for modules compiled for 2.[56] kernels and the old way just for 2.4
> > > kernels...
> > 
> > I don't really have an opinion on it, but it's not my call.

vmmon started using 'get_user_pages' for locking pages some time ago. 
Unfortunately userspace needs looking at VA->PA mapping from time to time 
although it already retrieved this information at the time get_user_pages() 
was invoked :-( It makes userspace simpler, and it was also much faster than
any other solution before pmd/pte moved into the high memory.
						Best regards,
							Petr Vandrovec
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
