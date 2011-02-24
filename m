Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 7FFCC8D0039
	for <linux-mm@kvack.org>; Thu, 24 Feb 2011 18:23:26 -0500 (EST)
Date: Fri, 25 Feb 2011 00:23:13 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 1/8] Fix interleaving for transparent hugepages v2
Message-ID: <20110224232313.GG23252@random.random>
References: <1298425922-23630-1-git-send-email-andi@firstfloor.org>
 <1298425922-23630-2-git-send-email-andi@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1298425922-23630-2-git-send-email-andi@firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>

For patches 1-5 and 8:

Acked-by: Andrea Arcangeli <aarcange@redhat.com>

Patch 6-7 I've to trust this branch is really worth it, I agree
khugepaged can hardly be better, but this comes at the cost of one
more branch for something that looks minor issue. I'm netural if
others likes it it's sure fine with me (I think David didn't like it
though, but he didn't answer to last email from Andi, I'm CCing him in
case he wants to elaborate further).

My patch incremental with patch 8 is also needed. My patch incremental
with patch 7 is also needed if 6-7 gets applied.

They're good to be in 2.6.38 but I don't rate them extremely urgent
with the exception of patch 1 that is already in -mm in fact.

In some ways this also shows how the default numa policy is
inefficient if the best it can do is to look at where the page was
allocated initially without any knowledge of where the task run last
but I don't want to risk making things worse, so for the short term
it's ok fix (it's not a band-aid it's really a fix for an heuristic
that is not good enough and it can't make things worse unlike the KSM
change in previous series that definitely made things worse), but I
hope in the long term getting info from the page in khugepaged won't
be needed anymore and it can be rolled back.

Thanks a lot Andi,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
