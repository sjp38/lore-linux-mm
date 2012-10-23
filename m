Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 186A46B0073
	for <linux-mm@kvack.org>; Mon, 22 Oct 2012 21:45:18 -0400 (EDT)
Message-ID: <1350956709.2728.20.camel@pasglop>
Subject: Re: [PATCH] MM: Support more pagesizes for MAP_HUGETLB/SHM_HUGETLB
 v6
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Tue, 23 Oct 2012 12:45:09 +1100
In-Reply-To: <CAKgNAkjsGp9HUpvhUfqbXnfrLbBsQRAKvOs=41-w3ZAE7yX+cA@mail.gmail.com>
References: <1350665289-7288-1-git-send-email-andi@firstfloor.org>
	 <CAHO5Pa0W-WGBaPvzdRJxYPdrg-K9guChswo3KJheK4BaRzsRwQ@mail.gmail.com>
	 <20121022132733.GQ16230@one.firstfloor.org>
	 <20121022133534.GR16230@one.firstfloor.org>
	 <CAKgNAkgQ6JZdwOsCAQ4Ak_gVXtav=TzgzW2tbk5jMUwxtMqOAg@mail.gmail.com>
	 <20121022153633.GK2095@tassilo.jf.intel.com>
	 <CAKgNAki=AL+KdYDdYnE8ZhjK-tUf5cZ163BWPe6GRM0rpi-z7w@mail.gmail.com>
	 <20121022161151.GS16230@one.firstfloor.org>
	 <CAKgNAkjsGp9HUpvhUfqbXnfrLbBsQRAKvOs=41-w3ZAE7yX+cA@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mtk.manpages@gmail.com
Cc: Andi Kleen <andi@firstfloor.org>, Andi Kleen <ak@linux.intel.com>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hillf Danton <dhillf@gmail.com>

On Mon, 2012-10-22 at 18:23 +0200, Michael Kerrisk (man-pages) wrote:
> Since PowerPC already allows 16GB page sizes, doesn't there need to be
> allowance for the possibility of future expansion? Choosing a larger
> minimum size (like 2^16) would allow that. Does the minimum size need
> to be 16k? (Surely, if you want a HUGEPAGE, you want a bigger page
> than that? I am not sure.)

I can't say for sure what we're going to come up with in 5 years but so
far, I am not aware of plans to go beyond 16G just yet :-)

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
