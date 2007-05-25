Date: Fri, 25 May 2007 17:05:33 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch 0/6] Compound Page Enhancements
Message-Id: <20070525170533.2987b7b2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070525051716.030494061@sgi.com>
References: <20070525051716.030494061@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, mel@csn.ul.ie, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On Thu, 24 May 2007 22:17:16 -0700
clameter@sgi.com wrote:

> This patch enhances the handling of compound pages in the VM. It may also
> be important also for the antifrag patches that need to manage a set of
> higher order free pages and also for other uses of compound pages.
> 
> For now it simplifies accounting for SLUB pages but the groundwork here is
> important for the large block size patches and for allowing to page migration
> of larger pages. With this framework we may be able to get to a point where
> compound pages keep their flags while they are free and Mel may avoid having
> special functions for determining the page order of higher order freed pages.
> If we can avoid the setup and teardown of higher order pages then allocation
> and release of compound pages will be faster.
> 

Keeping "free high order page" as "free compound page" in free_area[]-> and
avoid calling prep_compound_page() in page allocation ?

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
