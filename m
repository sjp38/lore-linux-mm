Date: Thu, 6 Oct 2005 08:11:28 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH 1/7] Fragmentation Avoidance V16: 001_antidefrag_flags
Message-Id: <20051006081128.62c9ab1f.pj@sgi.com>
In-Reply-To: <20051005144552.11796.52857.sendpatchset@skynet.csn.ul.ie>
References: <20051005144546.11796.1154.sendpatchset@skynet.csn.ul.ie>
	<20051005144552.11796.52857.sendpatchset@skynet.csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, akpm@osdl.org, kravetz@us.ibm.com, linux-kernel@vger.kernel.org, jschopp@austin.ibm.com, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

Mel wrote:
> +/* Allocation type modifiers, group together if possible */

Isn't that "if possible" bogus.  I thought these two bits
_had_ to be grouped together, at least with the current code.

What happened to the comment that Joel added to gpl.h:

+/* Allocation type modifiers, these are required to be adjacent
+ * __GPF_USER: Allocation for user page or a buffer page
+ * __GFP_KERNRCLM: Short-lived or reclaimable kernel allocation
+ * Both bits off: Kernel non-reclaimable or very hard to reclaim
+ * RCLM_SHIFT (defined elsewhere) depends on the location of these bits

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
