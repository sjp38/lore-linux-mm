Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id F19D26B0087
	for <linux-mm@kvack.org>; Mon, 26 Nov 2012 13:53:18 -0500 (EST)
Date: 26 Nov 2012 13:53:17 -0500
Message-ID: <20121126185317.10879.qmail@science.horizon.com>
From: "George Spelvin" <linux@horizon.com>
Subject: Re: 3.7-rc6 soft lockup in kswapd0
In-Reply-To: <20121126183242.GA9894@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org, linux@horizon.com
Cc: dave@linux.vnet.ibm.com, jack@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mgorman@suse.de, riel@redhat.com

Johannes Weiner <hannes@cmpxchg.org> wrote:
> Any chance you could test with this fix instead, in addition to Dave's
> accounting fix?  It's got bool and everything!

Okay.  Mel, speak up if you object.  I also rebased on top of 3.7-rc7,
which already includes Dave's fix.  Again, speak up if that's a bad idea.

> ---
> From: Johannes Weiner <hannes@cmpxchg.org>
> Subject: [patch] mm: vmscan: fix endless loop in kswapd balancing

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
