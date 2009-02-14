Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id A84476B003D
	for <linux-mm@kvack.org>; Sat, 14 Feb 2009 18:08:11 -0500 (EST)
Date: Sun, 15 Feb 2009 00:08:02 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [RFC v13][PATCH 00/14] Kernel based checkpoint/restart
Message-ID: <20090214230802.GE20477@elte.hu>
References: <1233076092-8660-1-git-send-email-orenl@cs.columbia.edu> <1234285547.30155.6.camel@nimitz> <20090211141434.dfa1d079.akpm@linux-foundation.org> <1234462282.30155.171.camel@nimitz> <20090213152836.0fbbfa7d.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090213152836.0fbbfa7d.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, orenl@cs.columbia.edu, linux-api@vger.kernel.org, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, viro@zeniv.linux.org.uk, hpa@zytor.com, tglx@linutronix.de
List-ID: <linux-mm.kvack.org>


* Andrew Morton <akpm@linux-foundation.org> wrote:

> Similar to the way in which perfectly correct and normal kernel
> sometimes has to be changed because it unexpectedly upsets the -rt
> patch.

Actually, regarding -rt, we try to keep that in two buckets:

 1) Normal kernel code works but is unclean or structured less
    than ideal. In this case we restructure the mainline code,
    but that change stands on its own four legs, without any
    -rt considerations.

 2) Normal kernel code that is clean - i.e. a change that only
    matters to -rt. In this case we dont touch the mainline code,
    nor do we bother mainline.

Do you know any specific example that falls outside of those categories?

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
