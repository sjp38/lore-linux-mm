Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 2FF426B0044
	for <linux-mm@kvack.org>; Thu, 22 Nov 2012 21:26:08 -0500 (EST)
Date: Fri, 23 Nov 2012 10:25:57 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: Problem in Page Cache Replacement
Message-ID: <20121123022557.GA3954@localhost>
References: <1353433362.85184.YahooMailNeo@web141101.mail.bf1.yahoo.com>
 <20121120182500.GH1408@quack.suse.cz>
 <1353485020.53500.YahooMailNeo@web141104.mail.bf1.yahoo.com>
 <1353485630.17455.YahooMailNeo@web141106.mail.bf1.yahoo.com>
 <50AC9220.70202@gmail.com>
 <20121121090204.GA9064@localhost>
 <50ACA209.9000101@gmail.com>
 <20121122152611.GA11736@localhost>
 <50AED214.4000701@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50AED214.4000701@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jaegeuk Hanse <jaegeuk.hanse@gmail.com>
Cc: metin d <metdos@yahoo.com>, Jan Kara <jack@suse.cz>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Jaegeuk,

> Thanks for your response. But which kind of pages are in the special
> reserved and which are all-flags-cleared?

The all-flags-cleared pages are mostly free pages in the buddy system.
The pages with flag "buddy" are also free pages: the buddy system only
marks the head pages of each order-2 free range with flag "buddy".

The reserved pages come from many sources, they may be set for memory
reserved for BIOS, memory holes, offlined memory, or used by some
device drivers.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
