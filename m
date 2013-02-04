Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id B8C1C6B0005
	for <linux-mm@kvack.org>; Sun,  3 Feb 2013 22:58:11 -0500 (EST)
Date: Mon, 4 Feb 2013 12:58:09 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v6 4/4] zram: get rid of lockdep warning
Message-ID: <20130204035809.GG2688@blaptop>
References: <1359513702-18709-1-git-send-email-minchan@kernel.org>
 <1359513702-18709-4-git-send-email-minchan@kernel.org>
 <20130204015333.GA6548@kroah.com>
 <20130204034208.GF2688@blaptop>
 <20130204035013.GA13954@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130204035013.GA13954@kroah.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Pekka Enberg <penberg@cs.helsinki.fi>, jmarchan@redhat.com

On Sun, Feb 03, 2013 at 07:50:13PM -0800, Greg Kroah-Hartman wrote:
> On Mon, Feb 04, 2013 at 12:42:08PM +0900, Minchan Kim wrote:
> > Hi Greg,
> > 
> > On Sun, Feb 03, 2013 at 05:53:33PM -0800, Greg Kroah-Hartman wrote:
> > > On Wed, Jan 30, 2013 at 11:41:42AM +0900, Minchan Kim wrote:
> > > > Lockdep complains about recursive deadlock of zram->init_lock.
> > > > [1] made it false positive because we can't request IO to zram
> > > > before setting disksize. Anyway, we should shut lockdep up to
> > > > avoid many reporting from user.
> > > > 
> > > > [1] : zram: force disksize setting before using zram
> > > > 
> > > > Acked-by: Jerome Marchand <jmarchand@redhat.com>
> > > > Acked-by: Nitin Gupta <ngupta@vflare.org>
> > > > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > > > ---
> > > >  drivers/staging/zram/zram_drv.c   |  189 +++++++++++++++++++------------------
> > > >  drivers/staging/zram/zram_drv.h   |   12 ++-
> > > >  drivers/staging/zram/zram_sysfs.c |   11 ++-
> > > >  3 files changed, 116 insertions(+), 96 deletions(-)
> > > 
> > > This patch fails to apply to my staging-next branch, but the three
> > > others did, so I took them.  Please refresh this one and resend if you
> > > want it applied.
> > 
> > We must have missed each other.
> 
> Yes, I was on a flight with no email :)
> 
> > A few hours ago, I sent to you v7 based on next-20130202.
> > https://lkml.org/lkml/2013/2/3/319
> > 
> > v7 includes acks of Jerome and resolve conflict with latest staging.
> > I believe it is okay to apply your tree.
> > 
> > Please reapply v7 instead of v6.
> 
> Please just send the one patch I need to apply here, I added Jerome's
> acks to the previous patches already.

Thanks!
