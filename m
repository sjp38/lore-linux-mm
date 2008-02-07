Subject: Re: [PATCH 1/3] hugetlb: numafy several functions
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20080206231558.GI3477@us.ibm.com>
References: <20080206231558.GI3477@us.ibm.com>
Content-Type: text/plain
Date: Thu, 07 Feb 2008 13:35:15 -0500
Message-Id: <1202409315.5298.65.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: wli@holomorphy.com, agl@us.ibm.com, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2008-02-06 at 15:15 -0800, Nishanth Aravamudan wrote:
> hugetlb: numafy several functions
> 

<snip>

Nish:  glad to see these surface again.  I'll add them [back] into my
tree for testing.  I'm at 24-mm1.  Can't tell from the messages what
release they're against, but I'll sort that out.

Another thing:  I've tended to test these atop Mel Gorman's zonelist
rework and a set of mempolicy cleanups that I'm holding pending
acceptance of Mel's patches.  I'll probably do that with these.  At some
point we need to sort out with Andrew when or whether Mel's patches will
hit -mm.  If so, what order vs yours...

Thanks,
Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
