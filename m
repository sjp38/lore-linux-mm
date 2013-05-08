Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 4A1DB6B005A
	for <linux-mm@kvack.org>; Wed,  8 May 2013 16:12:14 -0400 (EDT)
Date: Wed, 8 May 2013 13:12:05 -0700
From: =?utf-8?B?U8O2cmVu?= Brinkmann <soren.brinkmann@xilinx.com>
Subject: Re: [REGRESSION] SLAB allocator (on Zynq)
References: <9d9b2266-e09e-4366-80ef-3df5db775f25@TX2EHSMHS033.ehs.local>
 <20130508193906.GC32546@atomide.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Disposition: inline
In-Reply-To: <20130508193906.GC32546@atomide.com>
Message-ID: <35a77b0e-59cc-4fee-81cf-20c059462d12@DB8EHSMHS016.ehs.local>
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Lindgren <tony@atomide.com>
Cc: Michal Simek <michal.simek@xilinx.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org

On Wed, May 08, 2013 at 12:39:07PM -0700, Tony Lindgren wrote:
> Hi,
> =

> * S=C3=B6ren Brinkmann <soren.brinkmann@xilinx.com> [130508 12:26]:
> > Hi,
> > =

> > I compiled the latest kernel for Zynq and ran into issues when the SLAB=

> > allocator is selected. Booting crashes early with a NULL pointer
> > dereference (boot log attached).
> > Switching to the SLUB allocator resolves the issue (boot log attached).=

> =

> There's a fix for this now in lkml thread
> "[GIT PULL] SLAB changes for v3.10":
> 
> http://lkml.org/lkml/2013/5/8/374#
Thanks for the quick response and apologies for not having it found
myself earlier.
With that patch it works again.

	Thanks,
	S=C3=B6ren


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
