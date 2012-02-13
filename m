Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id D4A176B002C
	for <linux-mm@kvack.org>; Mon, 13 Feb 2012 16:55:33 -0500 (EST)
Received: by pbcwz17 with SMTP id wz17so6116329pbc.14
        for <linux-mm@kvack.org>; Mon, 13 Feb 2012 13:55:33 -0800 (PST)
Date: Mon, 13 Feb 2012 13:55:31 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] Ensure that walk_page_range()'s start and end are
 page-aligned
In-Reply-To: <87zkcm23az.fsf@caffeine.danplanet.com>
Message-ID: <alpine.DEB.2.00.1202131350500.17296@chino.kir.corp.google.com>
References: <1328902796-30389-1-git-send-email-danms@us.ibm.com> <alpine.DEB.2.00.1202130211400.4324@chino.kir.corp.google.com> <87zkcm23az.fsf@caffeine.danplanet.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Smith <danms@us.ibm.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 13 Feb 2012, Dan Smith wrote:

> DR> It doesn't "ensure" anything without CONFIG_DEBUG_VM enabled, which
> DR> isn't the default.
> 
> Are you proposing a change in verbiage or a stronger check? A
> VM_BUG_ON() seemed on par with other checks, such as the one in
> get_user_pages_fast().
> 

That's not a precedent, there's a big difference between the performance 
of gup_fast(), where we can't spare an additional compare and branch, and 
walk_page_range().  VM_BUG_ON() is typically used in situations where a 
debug kernel has been built, including CONFIG_DEBUG_VM, and the check 
helps to isolate a problem that would be otherwise difficult to find.  If 
that fits the criteria, fine, but it doesn't "ensure" walk_page_range() 
always has start and end addresses that are page aligned, so the changelog 
needs to be modified to describe why an error in this path wouldn't be 
evident.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
