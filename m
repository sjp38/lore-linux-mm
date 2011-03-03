Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 4D0BA8D0039
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 15:58:12 -0500 (EST)
Subject: Re: [PATCH] Make /proc/slabinfo 0400
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <1299174652.2071.12.camel@dan>
References: <1299174652.2071.12.camel@dan>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 03 Mar 2011 14:58:02 -0600
Message-ID: <1299185882.3062.233.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Rosenberg <drosenberg@vsecurity.com>
Cc: cl@linux-foundation.org, penberg@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 2011-03-03 at 12:50 -0500, Dan Rosenberg wrote:
> Allowing unprivileged users to read /proc/slabinfo represents a security
> risk, since revealing details of slab allocations can expose information
> that is useful when exploiting kernel heap corruption issues.  This is
> evidenced by observing that nearly all recent public exploits for heap
> issues rely on feedback from /proc/slabinfo to manipulate heap layout
> into an exploitable state.

Looking at a couple of these exploits, my suspicion is that looking at
slabinfo simply improves the odds of success by a small factor (ie 10x
or so) and doesn't present a real obstacle to attackers. All that
appears to be required is to arrange that an overrunnable object be
allocated next to one that is exploitable when overrun. And that can be
arranged with fairly high probability on SLUB's merged caches.

On the other hand, I'm not convinced the contents of this file are of
much use to people without admin access.

-- 
Mathematics is the supreme nostalgia of our time.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
