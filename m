Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id D3F446B002C
	for <linux-mm@kvack.org>; Fri, 10 Feb 2012 14:57:33 -0500 (EST)
From: Dan Smith <danms@us.ibm.com>
Subject: Re: [PATCH] Ensure that walk_page_range()'s start and end are page-aligned
References: <1328902796-30389-1-git-send-email-danms@us.ibm.com>
	<op.v9hahmw23l0zgt@mpn-glaptop>
Date: Fri, 10 Feb 2012 11:57:31 -0800
In-Reply-To: <op.v9hahmw23l0zgt@mpn-glaptop> (Michal Nazarewicz's message of
	"Fri, 10 Feb 2012 20:45:12 +0100")
Message-ID: <874nuy31hw.fsf@caffeine.danplanet.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

MN> Commit message says about walk_pte_range() but commit changes
MN> walk_page_range().

Yep, the issue occurs in walk_pte_range(). The goal was to ensure that
the external interface to it (which is walk_page_range()) does the check
and avoids doing the walk entirely. I think the expectation is that
walk_page_range() is used on aligned addresses. If we put the check in
walk_pte_range() then only walks with a pte_entry handler would fail on
unaligned addresses, which is potentially confusing.

MN> So why not change the condition to addr < end?

That would work, of course, but seems sloppier and less precise. The
existing code was clearly written expecting to walk aligned addresses.

-- 
Dan Smith
IBM Linux Technology Center
email: danms@us.ibm.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
