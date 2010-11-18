Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id D62236B008C
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 03:59:14 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAI8xBhl031329
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 18 Nov 2010 17:59:12 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id A122645DE4D
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 17:59:11 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 75B5245DE50
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 17:59:11 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 563731DB8045
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 17:59:11 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id BFAFF1DB803E
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 17:59:06 +0900 (JST)
Date: Thu, 18 Nov 2010 17:53:34 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] Make swap accounting default behavior configurable
Message-Id: <20101118175334.be00c8f2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20101118174654.8fa69aca.nishimura@mxp.nes.nec.co.jp>
References: <20101116101726.GA21296@tiehlicka.suse.cz>
	<20101116124615.978ed940.akpm@linux-foundation.org>
	<20101117092339.1b7c2d6d.nishimura@mxp.nes.nec.co.jp>
	<20101116171225.274019cf.akpm@linux-foundation.org>
	<20101117122801.e9850acf.nishimura@mxp.nes.nec.co.jp>
	<20101118082332.GB15928@tiehlicka.suse.cz>
	<20101118174654.8fa69aca.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, balbir@linux.vnet.ibm.com, stable@kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 18 Nov 2010 17:46:54 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> On Thu, 18 Nov 2010 09:23:32 +0100
> Michal Hocko <mhocko@suse.cz> wrote:
> 
> > On Wed 17-11-10 12:28:01, Daisuke Nishimura wrote:
> > > On Tue, 16 Nov 2010 17:12:25 -0800
> > > Andrew Morton <akpm@linux-foundation.org> wrote:
> > > 
> > > > On Wed, 17 Nov 2010 09:23:39 +0900 Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > > > 
> > > > > > > 
> > > > > > > diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
> > > > > > > index ed45e98..14eafa5 100644
> > > > > > > --- a/Documentation/kernel-parameters.txt
> > > > > > > +++ b/Documentation/kernel-parameters.txt
> > > > > > > @@ -2385,6 +2385,9 @@ and is between 256 and 4096 characters. It is defined in the file
> > > > > > >  			improve throughput, but will also increase the
> > > > > > >  			amount of memory reserved for use by the client.
> > > > > > >  
> > > > > > > +	swapaccount	[KNL] Enable accounting of swap in memory resource
> > > > > > > +			controller. (See Documentation/cgroups/memory.txt)
> > > > > > 
> > > > > > So we have swapaccount and noswapaccount.  Ho hum, "swapaccount=[1|0]"
> > > > > > would have been better.
> > > > > > 
> > > > > I suggested to keep "noswapaccount" for compatibility.
> > > > > If you and other guys don't like having two parameters, I don't stick to
> > > > > the old parameter.
> > > > > 
> > > > 
> > > > Yes, we're stuck with the old one now.
> > > > 
> > > > But we should note that "foo=[0|1]" is superior to "foo" and "nofoo". 
> > > > Even if we didn't initially intend to add "nofoo".
> > > > 
> > > I see.
> > > 
> > > Michal-san, could you update your patch to use "swapaccount=[1|0]" ?
> > 
> > I have noticed that Andrew has already taken the last version of the
> > patch for -mm tree. Should I still rework it to change swapaccount to
> > swapaccount=0|1 resp. true|false?
> > 
> It's usual to update a patch into more sophisticated one while it is in -mm tree.
> So, I think you'd better to do it(btw, I prefer 0|1 to true|false.
> Reading kernel-parameters.txt, 0|1 is more commonly used.).
> 

I vote for 0|1

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
