Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id DF1CE6B0169
	for <linux-mm@kvack.org>; Mon, 22 Aug 2011 03:52:51 -0400 (EDT)
Date: Mon, 22 Aug 2011 08:52:46 +0100
From: Chris Webb <chris@arachsys.com>
Subject: Re: Host where KSM appears to save a negative amount of memory
Message-ID: <20110822075246.GA2021@arachsys.com>
References: <20110821085614.GA3957@arachsys.com>
 <alpine.LSU.2.00.1108211155300.1252@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1108211155300.1252@sister.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org

Hugh Dickins <hughd@google.com> writes:

> KSM chooses to show the numbers pages_shared and pages_sharing as
> exclusive counts: pages_sharing indicates the saving being made.  So it
> would be perfectly reasonable to add those two numbers together to get
> the "total" number of pages sharing, the number you expected it to show;
> but it doesn't make sense to subtract shared from sharing.

Hi. Many thanks for your helpful and detailed explanation. I've fixed our
monitoring to correctly use just pages_sharing to measure the savings. I
think I just assumed the meanings of pages_shared and pages_sharing from
their names. This means that ksm has been saving even more memory than we
thought on our hosts in the past!

Best wishes,

Chris.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
