Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id AA2AC6007F3
	for <linux-mm@kvack.org>; Sun, 18 Jul 2010 20:09:30 -0400 (EDT)
Subject: Re: [S+Q2 07/19] slub: Allow removal of slab caches during boot
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <alpine.DEB.2.00.1007141647340.29110@chino.kir.corp.google.com>
References: <20100709190706.938177313@quilx.com>
	 <20100709190853.770833931@quilx.com>
	 <alpine.DEB.2.00.1007141647340.29110@chino.kir.corp.google.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 19 Jul 2010 10:07:10 +1000
Message-ID: <1279498030.10390.1760.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, Roland Dreier <rdreier@cisco.com>, linux-kernel@vger.kernel.org, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Wed, 2010-07-14 at 16:48 -0700, David Rientjes wrote:
> On Fri, 9 Jul 2010, Christoph Lameter wrote:
> 
> > If a slab cache is removed before we have setup sysfs then simply skip over
> > the sysfs handling.
> > 
> > Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> > Cc: Roland Dreier <rdreier@cisco.com>
> > Signed-off-by: Christoph Lameter <cl@linux-foundation.org>
> 
> Acked-by: David Rientjes <rientjes@google.com>
> 
> I missed this case earlier because I didn't consider slab caches being 
> created and destroyed prior to slab_state == SYSFS, sorry!

Ok so I may be a bit sleepy or something but I still fail to see how
this whole thing isn't totally racy...

AFAIK. By the time we switch the slab state, we -do- have all CPUs up
and can race happily between creating slab caches and creating the sysfs
files...

Ben.
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
