Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 89DDC6B0087
	for <linux-mm@kvack.org>; Mon,  6 Dec 2010 17:56:53 -0500 (EST)
Date: Mon, 6 Dec 2010 14:46:22 -0800
From: Greg KH <greg@kroah.com>
Subject: Re: [stable] [BUGFIX] memcg: avoid deadlock between move charge
 and try_charge()
Message-ID: <20101206224622.GN9265@kroah.com>
References: <20101116191748.d6645376.nishimura@mxp.nes.nec.co.jp>
 <20101116124117.64608b66.akpm@linux-foundation.org>
 <20101117092401.61c2117a.nishimura@mxp.nes.nec.co.jp>
 <20101126164825.24e684ca.nishimura@mxp.nes.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101126164825.24e684ca.nishimura@mxp.nes.nec.co.jp>
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: stable@kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri, Nov 26, 2010 at 04:48:25PM +0900, Daisuke Nishimura wrote:
> > > > Cc: <stable@kernel.org>
> > > 
> > > The patch doesn't apply well to 2.6.36 so if we do want it backported
> > > then please prepare a tested backport for the -stable guys?
> > > 
> > O.K.
> > I'll test a backported patch for 2.6.36.y and send it after this is merged into mainline.
> > 
> Done.
> 
> I've tested this backported patch on 2.6.36 and it works properly.
> There is no change in mm/memcontrol.c from v2.6.36 to v2.6.36.1, so
> this can be applied to 2.6.36.1 too.

Thanks for the patch, I've now queued it up for .36-stable.

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
