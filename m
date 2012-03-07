Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 013EF6B0092
	for <linux-mm@kvack.org>; Tue,  6 Mar 2012 19:26:21 -0500 (EST)
Date: Wed, 7 Mar 2012 01:26:16 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 1/2] ksm: clean up page_trans_compound_anon_split
Message-ID: <20120307002616.GP13462@redhat.com>
References: <1330594374-13497-1-git-send-email-lliubbo@gmail.com>
 <alpine.LSU.2.00.1203061515470.1292@eggly.anvils>
 <20120307001148.GO13462@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120307001148.GO13462@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Bob Liu <lliubbo@gmail.com>, akpm@linux-foundation.org, rientjes@google.com, kamezawa.hiroyu@jp.fujitsu.com, minchan.kim@gmail.com, linux-mm@kvack.org

On Wed, Mar 07, 2012 at 01:11:48AM +0100, Andrea Arcangeli wrote:
> (the function was invoked only on compound pages in the first place).

BTW, most certainly I did at some point this change:

-	if (page_trans_compound_anon_split(page))
+	if (PageTransCompound(page) && page_trans_compound_anon_split(page))

Before doing this change, the "cleaned up" version would have been
broken.

The original idea was to return 1 only in real error condition when a
THP splitting failure was encountered. So it had to be neutral and not
error out if split_huge_page wasn't needed.

In short the cleaned up version of page_trans_compound_anon_split is a
bit less generic but it being a static and only used here I don't mind
too much.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
