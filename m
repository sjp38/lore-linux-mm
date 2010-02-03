Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 957EA6B007D
	for <linux-mm@kvack.org>; Wed,  3 Feb 2010 11:06:32 -0500 (EST)
Received: by fg-out-1718.google.com with SMTP id e21so178387fga.8
        for <linux-mm@kvack.org>; Wed, 03 Feb 2010 08:06:30 -0800 (PST)
Subject: Re: Improving OOM killer
From: Minchan Kim <minchan.kim@gmail.com>
In-Reply-To: <1265209254.1052.24.camel@barrios-desktop>
References: <201002012302.37380.l.lunak@suse.cz>
	 <20100203085711.GF19641@balbir.in.ibm.com>
	 <201002031310.28271.l.lunak@suse.cz>
	 <20100203122526.GG19641@balbir.in.ibm.com>
	 <1265209254.1052.24.camel@barrios-desktop>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 04 Feb 2010 01:06:18 +0900
Message-ID: <1265213178.1052.50.camel@barrios-desktop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: Lubos Lunak <l.lunak@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Jiri Kosina <jkosina@suse.cz>
List-ID: <linux-mm.kvack.org>

On Thu, 2010-02-04 at 00:00 +0900, Minchan Kim wrote:
> On Wed, 2010-02-03 at 17:55 +0530, Balbir Singh wrote:
> > * Lubos Lunak <l.lunak@suse.cz> [2010-02-03 13:10:27]:
> >> >  I don't understand how this matters. Overcommit is memory for which address 
> > > space has been allocated but not actual memory, right? Then that's exactly 
> > > what I'm claiming is wrong and am trying to reverse. Currently OOM killer 
> > > takes this into account because it uses VmSize, but IMO it shouldn't - if a 
> > > process does malloc(400M) but then it uses only a tiny fraction of that, in 
> > > the case of memory shortage killing that process does not solve anything in 
> > > practice.
> > 
> > We have a way of tracking commmitted address space, which is more
> > sensible than just allocating memory and is used for tracking
> > overcommit. I was suggesting that, that might be a better approach.
> 
> Yes. It does make sense. At least total_vm doesn't care about
> MAP_NORESERVE case. But unfortunately, it's a per CPU not per Process.

Sorry for confusing. It was opposite. I slept :)
The commited as doesn't care about MAP_NORESERVE case. 
But it definitely charges memory. so I think total_vm is better than
committed as if we really have to use vmsize heuristic continuously.

But I am not sure that i understand your point about overcommit policy.


-- 
Kind regards,
Minchan Kim


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
