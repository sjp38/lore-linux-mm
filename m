Date: Sun, 16 Oct 2005 10:53:46 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH 0/8] Fragmentation Avoidance V17
Message-Id: <20051016105346.01c79929.pj@sgi.com>
In-Reply-To: <Pine.LNX.4.58.0510161255570.32005@skynet>
References: <20051011151221.16178.67130.sendpatchset@skynet.csn.ul.ie>
	<20051015195213.44e0dabb.pj@sgi.com>
	<Pine.LNX.4.58.0510161255570.32005@skynet>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: akpm@osdl.org, jschopp@austin.ibm.com, kravetz@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

Mel wrote:
> I would be happy with __GFP_USERRCLM but __GFP_EASYRCLM may be more
> obvious?

I would be delighted with either one.  Yes, __GFP_EASYRCLM is more obvious.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
