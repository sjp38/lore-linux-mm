Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 2362D8D0001
	for <linux-mm@kvack.org>; Mon,  1 Nov 2010 21:21:12 -0400 (EDT)
Date: Tue, 2 Nov 2010 09:20:06 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: 2.6.36 io bring the system to its knees
Message-ID: <20101102012006.GA3432@localhost>
References: <AANLkTimt7wzR9RwGWbvhiOmot_zzayfCfSh_-v6yvuAP@mail.gmail.com>
 <AANLkTikRKVBzO=ruy=JDmBF28NiUdJmAqb4-1VhK0QBX@mail.gmail.com>
 <AANLkTinzJ9a+9w7G5X0uZpX2o-L8E6XW98VFKoF1R_-S@mail.gmail.com>
 <AANLkTinDDG0ZkNFJZXuV9k3nJgueUW=ph8AuHgyeAXji@mail.gmail.com>
 <20101031012224.GA8007@localhost>
 <20101031015132.GA10086@localhost>
 <ial40e$jpj$1@dough.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ial40e$jpj$1@dough.gmane.org>
Sender: owner-linux-mm@kvack.org
To: Dimitrios Apostolou <jimis@gmx.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Nov 01, 2010 at 01:09:34AM +0000, Dimitrios Apostolou wrote:
> Hello, 
> 
> On Sun, 31 Oct 2010 09:51:32 +0800, Wu Fengguang wrote:
> > It may also help to lower the dirty ratio.
> > 
> > echo 5 > /proc/sys/vm/dirty_ratio
> > 
> > Memory pressure + heavy write can easily hurt responsiveness.
> > 
> > - eats up to 20% (the default value for dirty_ratio) memory with dirty
> >   pages and hence increase the memory pressure and number of swap IO
> 
> My experience has been different with that. Wouldn't it make more sense 
> to _increase_ dirty_ratio (to 50 lets say) and at the same time decrease 
> dirty_background_ratio? That way writing to disk starts early, but the 
> related apps stall waiting for I/O only when dirty_ratio is reached.

50% dirty ratio may help before the system goes thrashing (writing
processes will be throttled less/later). However Aidar is seeing hours
of unresponsiveness with heavy IO, in this case large dirty ratio
won't help reduce the throttling any more.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
