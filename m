Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 2403F6B0098
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 22:43:07 -0500 (EST)
Date: Wed, 17 Nov 2010 12:28:01 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH] Make swap accounting default behavior configurable
Message-Id: <20101117122801.e9850acf.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20101116171225.274019cf.akpm@linux-foundation.org>
References: <20101116101726.GA21296@tiehlicka.suse.cz>
	<20101116124615.978ed940.akpm@linux-foundation.org>
	<20101117092339.1b7c2d6d.nishimura@mxp.nes.nec.co.jp>
	<20101116171225.274019cf.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, balbir@linux.vnet.ibm.com, stable@kernel.org, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Tue, 16 Nov 2010 17:12:25 -0800
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Wed, 17 Nov 2010 09:23:39 +0900 Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > > > 
> > > > diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
> > > > index ed45e98..14eafa5 100644
> > > > --- a/Documentation/kernel-parameters.txt
> > > > +++ b/Documentation/kernel-parameters.txt
> > > > @@ -2385,6 +2385,9 @@ and is between 256 and 4096 characters. It is defined in the file
> > > >  			improve throughput, but will also increase the
> > > >  			amount of memory reserved for use by the client.
> > > >  
> > > > +	swapaccount	[KNL] Enable accounting of swap in memory resource
> > > > +			controller. (See Documentation/cgroups/memory.txt)
> > > 
> > > So we have swapaccount and noswapaccount.  Ho hum, "swapaccount=[1|0]"
> > > would have been better.
> > > 
> > I suggested to keep "noswapaccount" for compatibility.
> > If you and other guys don't like having two parameters, I don't stick to
> > the old parameter.
> > 
> 
> Yes, we're stuck with the old one now.
> 
> But we should note that "foo=[0|1]" is superior to "foo" and "nofoo". 
> Even if we didn't initially intend to add "nofoo".
> 
I see.

Michal-san, could you update your patch to use "swapaccount=[1|0]" ?

Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
