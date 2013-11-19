Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id 0B0506B0031
	for <linux-mm@kvack.org>; Mon, 18 Nov 2013 19:34:31 -0500 (EST)
Received: by mail-pb0-f54.google.com with SMTP id un15so1068229pbc.27
        for <linux-mm@kvack.org>; Mon, 18 Nov 2013 16:34:31 -0800 (PST)
Received: from psmtp.com ([74.125.245.152])
        by mx.google.com with SMTP id dk5si10806730pbc.106.2013.11.18.16.34.29
        for <linux-mm@kvack.org>;
        Mon, 18 Nov 2013 16:34:30 -0800 (PST)
Date: Mon, 18 Nov 2013 19:34:22 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1384821262-c0ms59jr-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <528A94C4.80101@sr71.net>
References: <20131115225550.737E5C33@viggo.jf.intel.com>
 <20131115225553.B0E9DFFB@viggo.jf.intel.com>
 <1384800714-y653r3ch-mutt-n-horiguchi@ah.jp.nec.com>
 <1384800841-314l1f3e-mutt-n-horiguchi@ah.jp.nec.com>
 <528A6448.3080907@sr71.net>
 <1384806022-4718p9lh-mutt-n-horiguchi@ah.jp.nec.com>
 <528A7D36.5020500@sr71.net>
 <1384811778-7euptzgp-mutt-n-horiguchi@ah.jp.nec.com>
 <528A94C4.80101@sr71.net>
Subject: Re: [PATCH] mm: call cond_resched() per MAX_ORDER_NR_PAGES pages copy
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, dave.jiang@intel.com, akpm@linux-foundation.org, dhillf@gmail.com, Mel Gorman <mgorman@suse.de>

On Mon, Nov 18, 2013 at 02:29:24PM -0800, Dave Hansen wrote:
> On 11/18/2013 01:56 PM, Naoya Horiguchi wrote:
> >> > Why bother trying to "optimize" it?
> > I thought that if we call cond_resched() too often, the copying thread can
> > take too long in a heavy load system, because the copying thread always
> > yields the CPU in every loop.
> 
> I think you're confusing cond_resched() and yield().  The way I look at it:
> 
> yield() means: "Hey scheduler, go right now and run something else I'm
> done running"
> 
> cond_resched() means: "Schedule me off if the scheduler has already
> decided something else _should_ be running"
> 
> I'm sure I'm missing some of the subtleties, but as I see it, yield()
> actively goes off and finds something else to run.  cond_resched() only
> schedules you off if you've *already* run too long.

I see.
Thanks for the explanation!

Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
