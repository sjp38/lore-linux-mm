Date: Wed, 28 Feb 2007 10:17:03 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [PATCH 2/5] lumpy: isolate_lru_pages wants to specifically take
 active or inactive pages
In-Reply-To: <f2cdac47f652dc10d19f6041997e85b1@kernel>
Message-ID: <Pine.LNX.4.64.0702281015340.21257@schroedinger.engr.sgi.com>
References: <exportbomb.1172604830@kernel> <f2cdac47f652dc10d19f6041997e85b1@kernel>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Tue, 27 Feb 2007, Andy Whitcroft wrote:

> The caller of isolate_lru_pages specifically knows whether it wants
> to take either inactive or active pages.  Currently we take the
> state of the LRU page at hand and use that to scan for matching
> pages in the order sized block.  If that page is transiting we
> can scan for the wrong type.  The caller knows what they want and
> should be telling us.  Pass in the required active/inactive state
> and match against that.

The page cannot be transiting since we hold the lru lock?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
