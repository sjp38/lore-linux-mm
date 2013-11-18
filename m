Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 431456B0031
	for <linux-mm@kvack.org>; Mon, 18 Nov 2013 17:30:23 -0500 (EST)
Received: by mail-pd0-f182.google.com with SMTP id v10so1620817pde.27
        for <linux-mm@kvack.org>; Mon, 18 Nov 2013 14:30:22 -0800 (PST)
Received: from psmtp.com ([74.125.245.168])
        by mx.google.com with SMTP id m9si10668605pba.143.2013.11.18.14.30.20
        for <linux-mm@kvack.org>;
        Mon, 18 Nov 2013 14:30:21 -0800 (PST)
Message-ID: <528A94C4.80101@sr71.net>
Date: Mon, 18 Nov 2013 14:29:24 -0800
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: call cond_resched() per MAX_ORDER_NR_PAGES pages
 copy
References: <20131115225550.737E5C33@viggo.jf.intel.com> <20131115225553.B0E9DFFB@viggo.jf.intel.com> <1384800714-y653r3ch-mutt-n-horiguchi@ah.jp.nec.com> <1384800841-314l1f3e-mutt-n-horiguchi@ah.jp.nec.com> <528A6448.3080907@sr71.net> <1384806022-4718p9lh-mutt-n-horiguchi@ah.jp.nec.com> <528A7D36.5020500@sr71.net> <1384811778-7euptzgp-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1384811778-7euptzgp-mutt-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, dave.jiang@intel.com, akpm@linux-foundation.org, dhillf@gmail.com, Mel Gorman <mgorman@suse.de>

On 11/18/2013 01:56 PM, Naoya Horiguchi wrote:
>> > Why bother trying to "optimize" it?
> I thought that if we call cond_resched() too often, the copying thread can
> take too long in a heavy load system, because the copying thread always
> yields the CPU in every loop.

I think you're confusing cond_resched() and yield().  The way I look at it:

yield() means: "Hey scheduler, go right now and run something else I'm
done running"

cond_resched() means: "Schedule me off if the scheduler has already
decided something else _should_ be running"

I'm sure I'm missing some of the subtleties, but as I see it, yield()
actively goes off and finds something else to run.  cond_resched() only
schedules you off if you've *already* run too long.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
