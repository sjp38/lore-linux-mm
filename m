Date: Wed, 15 Mar 2006 19:34:59 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: page migration reorg patch
Message-Id: <20060315193459.74993bfc.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0603151828001.30650@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0603151736380.30472@schroedinger.engr.sgi.com>
	<20060315175544.6f9adc59.akpm@osdl.org>
	<Pine.LNX.4.64.0603151828001.30650@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, marcelo.tosatti@cyclades.com, lee.schermerhorn@hp.com
List-ID: <linux-mm.kvack.org>

Christoph Lameter <clameter@sgi.com> wrote:
>
> On Wed, 15 Mar 2006, Andrew Morton wrote:
> 
>  > If you can rework this patch against
>  > http://www.zip.com.au/~akpm/linux/patches/stuff/x.bz2 (my current queue up
>  > to and including slab-leaks3-locking-fix.patch, against 2.6.16-rc6) then
>  > I'll be able to insert it in the right place and then fix up subsequent
>  > fallout, thanks.
> 
>  BTW compilation fails with:
> 
>  drivers/scsi/sata_vsc.c: At top level:
>  drivers/scsi/sata_vsc.c:254: unknown field `eh_timed_out' specified in 
>  initializer
>  drivers/scsi/sata_vsc.c:254: warning: initialization from incompatible 
>  pointer type
>

That's fairly typical for a new batch of git pulls :(

> 
>  The patch (including the two amendments) against the x.bz2 patch:

Thanks for doing that.

Yes, mm/mempolicy.c did get a bit uglified.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
