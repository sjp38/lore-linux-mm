Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 1E7BE6B006E
	for <linux-mm@kvack.org>; Mon, 22 Oct 2012 12:29:30 -0400 (EDT)
Date: Mon, 22 Oct 2012 09:29:29 -0700
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [PATCH] MM: Support more pagesizes for MAP_HUGETLB/SHM_HUGETLB v6
Message-ID: <20121022162929.GN2095@tassilo.jf.intel.com>
References: <1350665289-7288-1-git-send-email-andi@firstfloor.org>
 <CAHO5Pa0W-WGBaPvzdRJxYPdrg-K9guChswo3KJheK4BaRzsRwQ@mail.gmail.com>
 <20121022132733.GQ16230@one.firstfloor.org>
 <20121022133534.GR16230@one.firstfloor.org>
 <CAKgNAkgQ6JZdwOsCAQ4Ak_gVXtav=TzgzW2tbk5jMUwxtMqOAg@mail.gmail.com>
 <20121022153633.GK2095@tassilo.jf.intel.com>
 <CAKgNAki=AL+KdYDdYnE8ZhjK-tUf5cZ163BWPe6GRM0rpi-z7w@mail.gmail.com>
 <20121022161151.GS16230@one.firstfloor.org>
 <CAKgNAkjsGp9HUpvhUfqbXnfrLbBsQRAKvOs=41-w3ZAE7yX+cA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKgNAkjsGp9HUpvhUfqbXnfrLbBsQRAKvOs=41-w3ZAE7yX+cA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Cc: Andi Kleen <andi@firstfloor.org>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hillf Danton <dhillf@gmail.com>

> Since PowerPC already allows 16GB page sizes, doesn't there need to be
> allowance for the possibility of future expansion? Choosing a larger
> minimum size (like 2^16) would allow that. Does the minimum size need
> to be 16k? (Surely, if you want a HUGEPAGE, you want a bigger page
> than that? I am not sure.)

Some architectures have configurable huge page sizes, so it depends on
the user. I thought 16K is reasonable.  Can make it larger too. 

But I personally consider even 16GB pages somewhat too big.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
