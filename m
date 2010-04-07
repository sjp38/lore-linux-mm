Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 507C56B01EE
	for <linux-mm@kvack.org>; Wed,  7 Apr 2010 04:13:55 -0400 (EDT)
Date: Wed, 7 Apr 2010 16:13:51 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: Downsides to madvise/fadvise(willneed) for application startup
Message-ID: <20100407081351.GA20322@localhost>
References: <4BBA6776.5060804@mozilla.com> <20100406095135.GB5183@cmpxchg.org> <20100407022456.GA9468@localhost> <4BBBF402.70403@mozilla.com> <u2p28c262361004062106neea0a64ax2ee0d1e1caf7fce5@mail.gmail.com> <20100407071408.GA17892@localhost> <v2r28c262361004070033z43fc5f07jcb5581a7a8c48310@mail.gmail.com> <20100407074732.GC17892@localhost> <g2q28c262361004070106le671ad63u965e8137ad2e4f41@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <g2q28c262361004070106le671ad63u965e8137ad2e4f41@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Taras Glek <tglek@mozilla.com>, Johannes Weiner <hannes@cmpxchg.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Minchan,

> A few month ago, I saw your patch about enhancing readahead.
> At that time, many guys tested several size of USB and SSD which are
> consist of nand device.
> The result is good if we does readahead untile some crossover point.
> So I think we need readahead about file I/O in non-rotation device, too.
> 
> But startup latency is important than file I/O performance in some machine.
> With analysis at that time, code readahead of application affected slow startup.
> In addition, during bootup, cache hit ratio was very small.
> 
> So I hoped we can disable readahead just only code section(ie, roughly
> exec vma's filemap fault). :)
> 
> I don't want you to solve this problem right now.
> Just let you understand embedded system's some problem
> for enhancing readahead in future.  :)

Yeah, I've never heard of such a demand, definitely good to know it!

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
