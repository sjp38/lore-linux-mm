Date: Thu, 13 Dec 2007 00:53:46 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [RFC][PATCH 2/2] Revert "hugetlb: Add hugetlb_dynamic_pool sysctl"
Message-ID: <20071213085346.GC31637@holomorphy.com>
References: <20071213074156.GA17526@us.ibm.com> <20071213074259.GB17526@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20071213074259.GB17526@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: agl@us.ibm.com, mel@csn.ul.ie, apw@shadowen.org, akpm@linux-foundation.org, lee.schermerhorn@hp.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Dec 12, 2007 at 11:42:59PM -0800, Nishanth Aravamudan wrote:
> Revert "hugetlb: Add hugetlb_dynamic_pool sysctl"
> This reverts commit 54f9f80d6543fb7b157d3b11e2e7911dc1379790.
> Given the new sysctl nr_overcommit_hugepages, the boolean dynamic pool
> sysctl is not needed, as its semantics can be expressed by 0 in the
> overcommit sysctl (no dynamic pool) and non-0 in the overcommit sysctl
> (pool enabled).
> Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>

This is recent enough that dependencies shouldn't have developed, but
it'd be nice to stage user-visible API/ABI changes more consciously
and carefully in the future. Or at least we should try to avoid the
sorts of situations where we end up changing recently introduced
user/kernel ABI's and API's shortly after merging. We'll run the risk
of getting stuck with a user/kernel ABI we can't abandon for years on
account of not fixing it up before dependencies develop if this happens
too often.


-- wli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
