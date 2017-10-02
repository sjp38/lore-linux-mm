Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7BBCB6B0069
	for <linux-mm@kvack.org>; Mon,  2 Oct 2017 10:55:34 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id a7so12599633pfj.3
        for <linux-mm@kvack.org>; Mon, 02 Oct 2017 07:55:34 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id g10si8570792plt.477.2017.10.02.07.55.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 02 Oct 2017 07:55:33 -0700 (PDT)
Subject: Re: 4.14-rc2 on thinkpad x220: out of memory when inserting mmc card
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170905194739.GA31241@amd>
	<20171001093704.GA12626@amd>
	<20171001102647.GA23908@amd>
	<20171002144418.35mag5uormoqoay5@dhcp22.suse.cz>
In-Reply-To: <20171002144418.35mag5uormoqoay5@dhcp22.suse.cz>
Message-Id: <201710022355.CHB64510.SMLFJOVQHOOtFF@I-love.SAKURA.ne.jp>
Date: Mon, 2 Oct 2017 23:55:23 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, pavel@ucw.cz
Cc: linux-kernel@vger.kernel.org, adrian.hunter@intel.com, linux-mmc@vger.kernel.org, linux-mm@kvack.org

Michal Hocko wrote:
> On Sun 01-10-17 12:26:47, Pavel Machek wrote:
> > Hi!
> > 
> > > I inserted u-SD card, only to realize that it is not detected as it
> > > should be. And dmesg indeed reveals:
> > 
> > Tetsuo asked me to report this to linux-mm.
> > 
> > But 2^4 is 16 pages, IIRC that can't be expected to work reliably, and
> > thus this sounds like MMC bug, not mm bug.
> 
> Well, I cannot comment on why MMC needs such a large allocation and
> whether it can safely fall back to vmalloc but __GFP_RETRY_MAYFAIL
> might help to try harder and require compaction to do more work.
> Relying on that for correctness is, of course, a different story and
> a very unreliable under memory pressure or long term fragmented memory.

Linus Walleij answered that kvmalloc() is against the design of the bounce buffer at
http://lkml.kernel.org/r/CACRpkdYirC+rh_KALgVqKZMjq2DgbW4oi9MJkmrzwn+1O+94-g@mail.gmail.com .

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
