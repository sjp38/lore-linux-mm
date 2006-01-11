Date: Wed, 11 Jan 2006 14:42:55 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH 1/2] hugetlb: Delay page zeroing for faulted pages
Message-ID: <20060111224255.GD9091@holomorphy.com>
References: <1136920951.23288.5.camel@localhost.localdomain> <1137016960.9672.5.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1137016960.9672.5.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 11, 2006 at 04:02:40PM -0600, Adam Litke wrote:
> I've come up with a much better idea to resolve the issue I mention
> below.  The attached patch changes hugetlb_no_page to allocate unzeroed
> huge pages initially.  For shared mappings, we wait until after
> inserting the page into the page_cache succeeds before we zero it.  This
> has a side benefit of preventing the wasted zeroing that happened often
> in the original code.  The page_lock should guard against someone else
> using the page before it has been zeroed (but correct me if I am wrong
> here).  The patch doesn't completely close the race (there is a much
> smaller window without the zeroing though).  The next patch should close
> the race window completely.

Looks better to me.

Signed-off-by: William Irwin <wli@holomorphy.com>


-- wli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
