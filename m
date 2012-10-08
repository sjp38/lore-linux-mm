Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id EC4D76B002B
	for <linux-mm@kvack.org>; Mon,  8 Oct 2012 11:40:30 -0400 (EDT)
Date: Mon, 8 Oct 2012 17:38:56 +0200
From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: iwl3945: order 5 allocation during ifconfig up; vm problem?
Message-ID: <20121008153855.GA9737@redhat.com>
References: <20120909213228.GA5538@elf.ucw.cz>
 <alpine.DEB.2.00.1209091539530.16930@chino.kir.corp.google.com>
 <20120910111113.GA25159@elf.ucw.cz>
 <20120911162536.bd5171a1.akpm@linux-foundation.org>
 <20120912101826.GL11266@suse.de>
 <20121003113659.GD2259@redhat.com>
 <alpine.DEB.2.00.1210031104120.29765@chino.kir.corp.google.com>
 <20121005083659.GA2819@redhat.com>
 <20121006120850.GB18025@elf.ucw.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121006120850.GB18025@elf.ucw.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-wireless@vger.kernel.org, johannes.berg@intel.com, wey-yi.w.guy@intel.com, ilw@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, Oct 06, 2012 at 02:08:50PM +0200, Pavel Machek wrote:
> On Fri 2012-10-05 10:37:00, Stanislaw Gruszka wrote:
> > On Wed, Oct 03, 2012 at 11:07:13AM -0700, David Rientjes wrote:
> > > On Wed, 3 Oct 2012, Stanislaw Gruszka wrote:
> > > 
> > > > So, can this problem be solved like on below patch, or I should rather
> > > > split firmware loading into chunks similar like was already iwlwifi did?
> > 
> > Hmm, I looked at iwl3945 code and looks loading firmware in chunks is
> > nothing that can be easily done. 3945 bootstrap code expect that runtime
> > ucode will be placed in physically continue memory, and there are no
> > separate instructions for copy and for execute, just one to perform both
> > those actions. Maybe loading firmware in chunks can be done using
> > undocumented features of the device, but I'm eager to do this.
> 
> Just allocate memory during boot?

On driver I can reserve memory during module load, but also this isn't
something I prefer to do.
 
> > Pavel, do you still can reproduce this problem on released 3.6 ? 
> 
> It happened again yesterday on 3.6.0-rc6+. I don't think mm changed
> between -rc6 and final...

Could you check  __GFP_REPEAT oneline patch posted previously ?
And if that fail again, provide full dmesg (on your previous messages
there is vmap() failure, which I do not understand, where it come
from) ?

Thanks
Stanislaw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
