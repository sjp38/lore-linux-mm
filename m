Date: Tue, 22 Nov 2005 19:45:13 -0800
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH 1/5] Light fragmentation avoidance without usemap:
 001_antidefrag_flags
Message-Id: <20051122194513.3883d135.pj@sgi.com>
In-Reply-To: <20051122191715.21757.82818.sendpatchset@skynet.csn.ul.ie>
References: <20051122191710.21757.67440.sendpatchset@skynet.csn.ul.ie>
	<20051122191715.21757.82818.sendpatchset@skynet.csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, nickpiggin@yahoo.com.au, ak@suse.de, linux-kernel@vger.kernel.org, lhms-devel@lists.sourceforge.net, mingo@elte.hu
List-ID: <linux-mm.kvack.org>

+#define __GFP_EASYRCLM   ((__force gfp_t)0x40000u) /* Easily reclaimed page */

Acked (this one line) by pj <grin>.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
