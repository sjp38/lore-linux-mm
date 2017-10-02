Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9536A6B0033
	for <linux-mm@kvack.org>; Mon,  2 Oct 2017 10:44:22 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id p5so15334995pgn.7
        for <linux-mm@kvack.org>; Mon, 02 Oct 2017 07:44:22 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y11si3055221pln.146.2017.10.02.07.44.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 02 Oct 2017 07:44:21 -0700 (PDT)
Date: Mon, 2 Oct 2017 16:44:18 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: 4.14-rc2 on thinkpad x220: out of memory when inserting mmc card
Message-ID: <20171002144418.35mag5uormoqoay5@dhcp22.suse.cz>
References: <20170905194739.GA31241@amd>
 <20171001093704.GA12626@amd>
 <20171001102647.GA23908@amd>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171001102647.GA23908@amd>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: kernel list <linux-kernel@vger.kernel.org>, adrian.hunter@intel.com, linux-mmc@vger.kernel.org, linux-mm@kvack.org, penguin-kernel@I-love.SAKURA.ne.jp

On Sun 01-10-17 12:26:47, Pavel Machek wrote:
> Hi!
> 
> > I inserted u-SD card, only to realize that it is not detected as it
> > should be. And dmesg indeed reveals:
> 
> Tetsuo asked me to report this to linux-mm.
> 
> But 2^4 is 16 pages, IIRC that can't be expected to work reliably, and
> thus this sounds like MMC bug, not mm bug.

Well, I cannot comment on why MMC needs such a large allocation and
whether it can safely fall back to vmalloc but __GFP_RETRY_MAYFAIL
might help to try harder and require compaction to do more work.
Relying on that for correctness is, of course, a different story and
a very unreliable under memory pressure or long term fragmented memory.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
