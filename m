Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id B52189000BD
	for <linux-mm@kvack.org>; Thu, 29 Sep 2011 16:19:34 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: RFC -- new zone type
References: <20110928180909.GA7007@labbmf-linux.qualcomm.com>
Date: Thu, 29 Sep 2011 13:19:32 -0700
In-Reply-To: <20110928180909.GA7007@labbmf-linux.qualcomm.com> (Larry Bassel's
	message of "Wed, 28 Sep 2011 11:09:09 -0700")
Message-ID: <m2aa9nhzjf.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Larry Bassel <lbassel@codeaurora.org>
Cc: linux-mm@kvack.org, vgandhi@codeaurora.org

Larry Bassel <lbassel@codeaurora.org> writes:
>
> It was suggested to me that a new zone type which would be similar
> to the "movable zone" but is only allowed to contain pages
> that can be discarded (such as text) could solve this problem,

This may not actually be a win because if the text pages are needed
afterwards the act of rereading them from disk would likely take longer
than the copying.

The so you many not get latency before, but after.

Essentially robbing Peter to pay Paul.

If the goal is to just spread the latency over a longer time
I'm sure there are better ways to do that than to add a new zone.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
