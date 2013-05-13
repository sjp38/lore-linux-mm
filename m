Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 1E08C6B0002
	for <linux-mm@kvack.org>; Mon, 13 May 2013 04:40:12 -0400 (EDT)
Date: Mon, 13 May 2013 09:40:08 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [Query] Performance degradation with memory compaction (on QC
 chip-set)
Message-ID: <20130513084008.GO11497@suse.de>
References: <1310394396.24243.YahooMailNeo@web162006.mail.bf1.yahoo.com>
 <20110711145448.GI15285@suse.de>
 <1310462107.89450.YahooMailNeo@web162007.mail.bf1.yahoo.com>
 <20110712093510.GB7529@suse.de>
 <1310484381.60694.YahooMailNeo@web162011.mail.bf1.yahoo.com>
 <20110712154404.GD7529@suse.de>
 <1368414026.58026.YahooMailNeo@web160103.mail.bf1.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1368414026.58026.YahooMailNeo@web160103.mail.bf1.yahoo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: PINTU KUMAR <pintu_agarwal@yahoo.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Sun, May 12, 2013 at 08:00:26PM -0700, PINTU KUMAR wrote:
> Dear Mel Gorman,
> 
> I have one question about memory compaction.
> Kernel version: kernel-3.4 (ARM)
> Chipset: Qual-Comm MSM8930 dual-core.
> 
> We wanted to enable CONFIG_COMPACTION for our product with kernel-3.4.
> But QC commented that, enabling compaction on their chip-set is causing performance degradation for some streaming scenarios (from the beginning).
> 
> I wanted to know is this possible always?
> We used compaction with exynos processor and did not observe any performance degradation.
> 

I suspect one of their drivers are using high-order allocations and
hitting compaction as a result. Compaction is not guaranteed to cause
overhead but if it's in use then the scanning and copying overhead can
cause problems.

> Please let me know your comments.
> It will be helpful to decide on enabling compaction or not.
> 

Depends on workload and drivers.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
