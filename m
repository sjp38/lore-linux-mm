Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 933616B002B
	for <linux-mm@kvack.org>; Mon, 24 Sep 2012 05:04:12 -0400 (EDT)
Date: Mon, 24 Sep 2012 12:03:53 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: iwl3945: order 5 allocation during ifconfig up; vm problem?
Message-ID: <20120924090353.GA5368@mwanda>
References: <20120909213228.GA5538@elf.ucw.cz>
 <alpine.DEB.2.00.1209091539530.16930@chino.kir.corp.google.com>
 <20120910111113.GA25159@elf.ucw.cz>
 <20120911162536.bd5171a1.akpm@linux-foundation.org>
 <1347426988.13103.684.camel@edumazet-glaptop>
 <20120912055712.GE11613@merlins.org>
 <1347432846.4293.0.camel@jlt4.sipsolutions.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1347432846.4293.0.camel@jlt4.sipsolutions.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Berg <johannes@sipsolutions.net>
Cc: Marc MERLIN <marc@merlins.org>, Eric Dumazet <eric.dumazet@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Pavel Machek <pavel@ucw.cz>, David Rientjes <rientjes@google.com>, sgruszka@redhat.com, linux-wireless@vger.kernel.org, wey-yi.w.guy@intel.com, ilw@linux.intel.com, Andrew Morton <akpm@osdl.org>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Sep 12, 2012 at 08:54:06AM +0200, Johannes Berg wrote:
> On Tue, 2012-09-11 at 22:57 -0700, Marc MERLIN wrote:
> > On Wed, Sep 12, 2012 at 07:16:28AM +0200, Eric Dumazet wrote:
> > > On Tue, 2012-09-11 at 16:25 -0700, Andrew Morton wrote:
> > > 
> > > > Asking for a 256k allocation is pretty crazy - this is an operating
> > > > system kernel, not a userspace application.
> > > > 
> > > > I'm wondering if this is due to a recent change, but I'm having trouble
> > > > working out where the allocation call site is.
> > > > --
> > > 
> > > (Adding Marc Merlin to CC, since he reported same problem)
> > > 
> > > Thats the firmware loading in iwlwifi driver. Not sure if it can use SG.
> > > 
> > > drivers/net/wireless/iwlwifi/iwl-drv.c
> > > 
> > > iwl_alloc_ucode() -> iwl_alloc_fw_desc() -> dma_alloc_coherent()

I'm filing bugzilla entries for regressions.  What's the status on
this?

regards,
dan carpenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
