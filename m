Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 5DFAA6B01EE
	for <linux-mm@kvack.org>; Tue,  6 Apr 2010 01:03:28 -0400 (EDT)
Date: Tue, 6 Apr 2010 13:03:25 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH]vmscan: handle underflow for get_scan_ratio
Message-ID: <20100406050325.GA17797@localhost>
References: <20100331045348.GA3396@sli10-desk.sh.intel.com> <20100331142708.039E.A69D9226@jp.fujitsu.com> <20100331145030.03A1.A69D9226@jp.fujitsu.com> <20100402065052.GA28027@sli10-desk.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100402065052.GA28027@sli10-desk.sh.intel.com>
Sender: owner-linux-mm@kvack.org
To: "Li, Shaohua" <shaohua.li@intel.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Shaohua,

> +		scan = zone_nr_lru_pages(zone, sc, l);
> +		if (priority) {
> +			scan >>= priority;
> +			scan = (scan * fraction[file] / denominator[file]);

Ah, the (scan * fraction[file]) may overflow in 32bit kernel!

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
