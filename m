Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 01BAC6B13F0
	for <linux-mm@kvack.org>; Mon, 13 Feb 2012 05:12:24 -0500 (EST)
Received: by dadv6 with SMTP id v6so5353758dad.14
        for <linux-mm@kvack.org>; Mon, 13 Feb 2012 02:12:24 -0800 (PST)
Date: Mon, 13 Feb 2012 02:12:21 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] Ensure that walk_page_range()'s start and end are
 page-aligned
In-Reply-To: <1328902796-30389-1-git-send-email-danms@us.ibm.com>
Message-ID: <alpine.DEB.2.00.1202130211400.4324@chino.kir.corp.google.com>
References: <1328902796-30389-1-git-send-email-danms@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Smith <danms@us.ibm.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 10 Feb 2012, Dan Smith wrote:

> The inner function walk_pte_range() increments "addr" by PAGE_SIZE after
> each pte is processed, and only exits the loop if the result is equal to
> "end". Current, if either (or both of) the starting or ending addresses
> passed to walk_page_range() are not page-aligned, then we will never
> satisfy that exit condition and begin calling the pte_entry handler with
> bad data.
> 
> To be sure that we will land in the right spot, this patch checks that
> both "addr" and "end" are page-aligned in walk_page_range() before starting
> the traversal.
> 

It doesn't "ensure" anything without CONFIG_DEBUG_VM enabled, which isn't 
the default.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
