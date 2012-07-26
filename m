Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 32E3F6B0044
	for <linux-mm@kvack.org>; Thu, 26 Jul 2012 14:39:27 -0400 (EDT)
Message-ID: <50118E7F.8000609@redhat.com>
Date: Thu, 26 Jul 2012 14:37:51 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH -alternative] mm: hugetlbfs: Close race during teardown
 of hugetlbfs shared page tables V2 (resend)
References: <20120720134937.GG9222@suse.de> <20120720141108.GH9222@suse.de> <20120720143635.GE12434@tiehlicka.suse.cz> <20120720145121.GJ9222@suse.de> <alpine.LSU.2.00.1207222033030.6810@eggly.anvils>
In-Reply-To: <alpine.LSU.2.00.1207222033030.6810@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Linux-MM <linux-mm@kvack.org>, David Gibson <david@gibson.dropbear.id.au>, Ken Chen <kenchen@google.com>, Cong Wang <xiyou.wangcong@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Larry Woodman <lwoodman@redhat.com>

On 07/23/2012 12:04 AM, Hugh Dickins wrote:

> I spent hours trying to dream up a better patch, trying various
> approaches.  I think I have a nice one now, what do you think?  And
> more importantly, does it work?  I have not tried to test it at all,
> that I'm hoping to leave to you, I'm sure you'll attack it with gusto!
>
> If you like it, please take it over and add your comments and signoff
> and send it in.  The second part won't come up in your testing, and could
> be made a separate patch if you prefer: it's a related point that struck
> me while I was playing with a different approach.
>
> I'm sorely tempted to leave a dangerous pair of eyes off the Cc,
> but that too would be unfair.
>
> Subject-to-your-testing-
> Signed-off-by: Hugh Dickins <hughd@google.com>

This patch looks good to me.

Larry, does Hugh's patch survive your testing?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
