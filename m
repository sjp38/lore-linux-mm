Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 0614E6B004F
	for <linux-mm@kvack.org>; Wed, 16 Sep 2009 16:01:56 -0400 (EDT)
Date: Wed, 16 Sep 2009 13:00:17 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.32 -mm merge plans
Message-Id: <20090916130017.a848addb.akpm@linux-foundation.org>
In-Reply-To: <200909160900.10057.bjorn.helgaas@hp.com>
References: <20090915161535.db0a6904.akpm@linux-foundation.org>
	<20090916034650.GD2756@core.coreip.homeip.net>
	<20090915211408.bb614be5.akpm@linux-foundation.org>
	<200909160900.10057.bjorn.helgaas@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Bjorn Helgaas <bjorn.helgaas@hp.com>
Cc: dmitry.torokhov@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, david@hardeman.nu, lenb@kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 16 Sep 2009 09:00:09 -0600
Bjorn Helgaas <bjorn.helgaas@hp.com> wrote:

> On Tuesday 15 September 2009 10:14:08 pm Andrew Morton wrote:
> > On Tue, 15 Sep 2009 20:46:50 -0700 Dmitry Torokhov <dmitry.torokhov@gmail.com> wrote:
> > > > input-add-a-shutdown-method-to-pnp-drivers.patch
> > > 
> > > This should go through PNP tree (do we have one?).
> > 
> > Not really.  Bjorn heeps an eye on pnp.  Sometimes merges through acpi,
> > sometimes through -mm.
> > 
> > I'll merge it I guess, but where is the corresponding change to the
> > winbond driver?
> 
> I think this change looks good, and I think the winbond driver uses it.
> I don't object to it going in via -mm so it stays together with the
> winbond driver itself.

OK.  I renamed it to "pnp: add a shutdown method to pnp drivers" as
it's not an input patch at all.

I see it actually has your signed-off-by: in it already.

Now I need to work out where that winbond patch got to.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
