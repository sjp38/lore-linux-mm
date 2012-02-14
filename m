Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 5433C6B13F1
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 09:59:54 -0500 (EST)
From: Dan Smith <danms@us.ibm.com>
Subject: Re: [PATCH] Ensure that walk_page_range()'s start and end are page-aligned
References: <1328902796-30389-1-git-send-email-danms@us.ibm.com>
	<alpine.DEB.2.00.1202130211400.4324@chino.kir.corp.google.com>
	<87zkcm23az.fsf@caffeine.danplanet.com>
	<alpine.DEB.2.00.1202131350500.17296@chino.kir.corp.google.com>
Date: Tue, 14 Feb 2012 06:59:51 -0800
In-Reply-To: <alpine.DEB.2.00.1202131350500.17296@chino.kir.corp.google.com>
	(David Rientjes's message of "Mon, 13 Feb 2012 13:55:31 -0800 (PST)")
Message-ID: <87pqdh1mvs.fsf@caffeine.danplanet.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

DR> That's not a precedent, there's a big difference between the
DR> performance of gup_fast(), where we can't spare an additional
DR> compare and branch, and walk_page_range().  VM_BUG_ON() is typically
DR> used in situations where a debug kernel has been built, including
DR> CONFIG_DEBUG_VM, and the check helps to isolate a problem that would
DR> be otherwise difficult to find.

Okay, fair enough. I was trying to stay in line with the other
conventions, knowing that the check would only be done with
CONFIG_DEBUG_VM enabled.

I'd rather just make it always do the check in walk_page_range(). Does
that sound reasonable?

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
