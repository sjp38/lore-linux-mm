Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 1BFF98D0017
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 03:35:48 -0500 (EST)
Date: Mon, 15 Nov 2010 09:35:40 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC PATCH] Make swap accounting default behavior configurable
 v3
Message-ID: <20101115083540.GA20156@tiehlicka.suse.cz>
References: <20101110125154.GC5867@tiehlicka.suse.cz>
 <20101111094613.eab2ec0b.nishimura@mxp.nes.nec.co.jp>
 <20101111093155.GA20630@tiehlicka.suse.cz>
 <20101112094118.b02b669f.nishimura@mxp.nes.nec.co.jp>
 <20101112083103.GB7285@tiehlicka.suse.cz>
 <20101115101335.8880fd87.nishimura@mxp.nes.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101115101335.8880fd87.nishimura@mxp.nes.nec.co.jp>
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, balbir@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

On Mon 15-11-10 10:13:35, Daisuke Nishimura wrote:
> On Fri, 12 Nov 2010 09:31:03 +0100
[...]
> > diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
> > index ed45e98..7077148 100644
> > --- a/Documentation/kernel-parameters.txt
> > +++ b/Documentation/kernel-parameters.txt
> > @@ -1752,6 +1752,8 @@ and is between 256 and 4096 characters. It is defined in the file
> >  
> >  	noswapaccount	[KNL] Disable accounting of swap in memory resource
> >  			controller. (See Documentation/cgroups/memory.txt)
> > +	swapaccount	[KNL] Enable accounting of swap in memory resource
> > +			controller. (See Documentation/cgroups/memory.txt)
> >  
> >  	nosync		[HW,M68K] Disables sync negotiation for all devices.
> >  
> (I've add Andrew and Balbir to CC-list.)
> It seems that almost all parameters are listed in alphabetic order in the document,
> so I think it would be better to obey the rule.

You are right. The header of the file says:

" The following is a consolidated list of the kernel parameters as
implemented (mostly) by the __setup() macro and sorted into English
Dictionary order (defined as ignoring all punctuation and sorting digits
before letters in a case insensitive manner), and with descriptions
where known."

Updated patch follows bellow.

> 
> Thanks,
> Daisuke Nishimura.

Changes since v2:
* put the new parameter description to the proper (alphabetically sorted)
  place in Documentation/kernel-parameters.txt

Changes since v1:
* do not remove noswapaccount parameter and add swapaccount parameter instead
* Documentation/kernel-parameters.txt updated
---
