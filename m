Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 0FB5C6B01F3
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 04:13:39 -0400 (EDT)
Date: Tue, 30 Mar 2010 16:13:40 +0800
From: Shaohua Li <shaohua.li@intel.com>
Subject: Re: [PATCH]vmscan: handle underflow for get_scan_ratio
Message-ID: <20100330081340.GA23691@sli10-desk.sh.intel.com>
References: <20100330153750.8EA2.A69D9226@jp.fujitsu.com>
 <20100330065358.GA24828@sli10-desk.sh.intel.com>
 <20100330160820.8EA8.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100330160820.8EA8.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "Wu, Fengguang" <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

On Tue, Mar 30, 2010 at 03:31:40PM +0800, KOSAKI Motohiro wrote:
> > > > > Very unfortunately, this patch isn't acceptable. In past time, vmscan 
> > > > > had similar logic, but 1% swap-out made lots bug reports. 
> > > > can you elaborate this?
> > > > Completely restore previous behavior (do full scan with priority 0) is
> > > > ok too.
> > > 
> > > This is a option. but we need to know the root cause anyway.
> > I thought I mentioned the root cause in first mail. My debug shows
> > recent_rotated[0] is big, but recent_rotated[1] is almost zero, which makes
> > percent[0] 0. But you can double check too.
> 
> To revert can save percent[0]==0 && priority==0 case. but it shouldn't
> happen, I think. It mean to happen big latency issue.
> 
> Can you please try following patch? Also, I'll prepare reproduce environment soon.
still oom with the patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
