Date: Tue, 14 Aug 2007 12:11:59 -0700
From: Andy Isaacson <adi@hexapodia.org>
Subject: Re: [PATCH 3/4] Embed zone_id information within the zonelist->zones pointer
Message-ID: <20070814191158.GB14093@hexapodia.org>
References: <Pine.LNX.4.64.0708131457190.28445@schroedinger.engr.sgi.com> <20070813225841.GG3406@bingen.suse.de> <Pine.LNX.4.64.0708131506030.28502@schroedinger.engr.sgi.com> <20070813230801.GH3406@bingen.suse.de> <Pine.LNX.4.64.0708131536340.29946@schroedinger.engr.sgi.com> <20070813234322.GJ3406@bingen.suse.de> <Pine.LNX.4.64.0708131553050.30626@schroedinger.engr.sgi.com> <20070814000041.GL3406@bingen.suse.de> <20070814002223.2d8d42c5@the-village.bc.nu> <20070814001441.GN3406@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070814001441.GN3406@bingen.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Christoph Lameter <clameter@sgi.com>, Mel Gorman <mel@skynet.ie>, Lee.Schermerhorn@hp.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-mips@linux-mips.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 14, 2007 at 02:14:41AM +0200, Andi Kleen wrote:
> On Tue, Aug 14, 2007 at 12:22:23AM +0100, Alan Cox wrote:
> > > The only tricky part were skbs in a few drivers, but luckily they are only
> > > needed for bouncing which can be done without a skb too. For RX it adds
> > > one copy, but we can live with that because they're only slow devices.
> > 
> > Usually found on slow hardware that can't cope with extra copies very
> > well.
> 
> It's essentially only lance, meth, b44 and bcm43xx and lots of s390.
> 
> meth is only used on SGI O2s which are not that slow and unlikely
> to work in tree anyways.
> 
> b44 and bcm43xx run in fast enough new systems to have no trouble
> with copies.

bcm43xx hardware does show up on low-end MIPS boxes (wrt54g anybody?)
that would be sorely hurt by excess copies.

-andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
