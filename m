Date: Wed, 2 Nov 2005 16:11:34 +1100
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [Lhms-devel] [PATCH 0/7] Fragmentation Avoidance V19
Message-Id: <20051102161134.25f3b85d.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.58.0511011358520.14884@skynet>
References: <20051030235440.6938a0e9.akpm@osdl.org>
	<27700000.1130769270@[10.10.2.4]>
	<4366A8D1.7020507@yahoo.com.au>
	<Pine.LNX.4.58.0510312333240.29390@skynet>
	<4366C559.5090504@yahoo.com.au>
	<Pine.LNX.4.58.0511010137020.29390@skynet>
	<4366D469.2010202@yahoo.com.au>
	<Pine.LNX.4.58.0511011014060.14884@skynet>
	<20051101135651.GA8502@elte.hu>
	<Pine.LNX.4.58.0511011358520.14884@skynet>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: mingo@elte.hu, nickpiggin@yahoo.com.au, mbligh@mbligh.org, kravetz@us.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

Mel Gorman <mel@csn.ul.ie> wrote:
>
> As GFP_ATOMIC and GFP_NOFS cannot do
>  any reclaim work themselves

Both GFP_NOFS and GFP_NOIO can indeed perform direct reclaim.   All
we require is __GFP_WAIT.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
