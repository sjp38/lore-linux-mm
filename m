Date: Thu, 14 Dec 2006 20:57:34 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 1/4] lumpy reclaim v2
Message-Id: <20061214205734.0e385643.akpm@osdl.org>
In-Reply-To: <6109d33145c0dcf3a8a3a6bd120d7985@pinky>
References: <exportbomb.1165424343@pinky>
	<6109d33145c0dcf3a8a3a6bd120d7985@pinky>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 6 Dec 2006 16:59:35 +0000
Andy Whitcroft <apw@shadowen.org> wrote:

> +			tmp = __pfn_to_page(pfn);

ia64 doesn't implement __page_to_pfn.  Why did you not use page_to_pfn()?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
