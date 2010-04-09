Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id AF57B6B022E
	for <linux-mm@kvack.org>; Fri,  9 Apr 2010 17:25:16 -0400 (EDT)
Message-ID: <4BBF9B34.5040909@redhat.com>
Date: Fri, 09 Apr 2010 17:25:08 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH]vmscan: handle underflow for get_scan_ratio
References: <20100331045348.GA3396@sli10-desk.sh.intel.com>	<20100331142708.039E.A69D9226@jp.fujitsu.com>	<20100331145030.03A1.A69D9226@jp.fujitsu.com>	<20100402065052.GA28027@sli10-desk.sh.intel.com>	<20100406050325.GA17797@localhost>	<20100409065104.GA21480@sli10-desk.sh.intel.com> <20100409142057.be0ce5af.akpm@linux-foundation.org>
In-Reply-To: <20100409142057.be0ce5af.akpm@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Shaohua Li <shaohua.li@intel.com>, "Wu, Fengguang" <fengguang.wu@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On 04/09/2010 05:20 PM, Andrew Morton wrote:

> Come to that, it's not obvious that we need this in 2.6.34 either.  What
> is the user-visible impact here?

I suspect very little impact, especially during workloads
where we can just reclaim clean page cache at DEF_PRIORITY.
FWIW, the patch looks good to me, so:

Acked-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
