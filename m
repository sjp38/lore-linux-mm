Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 247A96B0073
	for <linux-mm@kvack.org>; Mon, 22 Oct 2012 21:44:44 -0400 (EDT)
Message-ID: <1350956664.2728.19.camel@pasglop>
Subject: Re: [PATCH] MM: Support more pagesizes for MAP_HUGETLB/SHM_HUGETLB
 v6
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Tue, 23 Oct 2012 12:44:24 +1100
In-Reply-To: <CAKgNAki=AL+KdYDdYnE8ZhjK-tUf5cZ163BWPe6GRM0rpi-z7w@mail.gmail.com>
References: <1350665289-7288-1-git-send-email-andi@firstfloor.org>
	 <CAHO5Pa0W-WGBaPvzdRJxYPdrg-K9guChswo3KJheK4BaRzsRwQ@mail.gmail.com>
	 <20121022132733.GQ16230@one.firstfloor.org>
	 <20121022133534.GR16230@one.firstfloor.org>
	 <CAKgNAkgQ6JZdwOsCAQ4Ak_gVXtav=TzgzW2tbk5jMUwxtMqOAg@mail.gmail.com>
	 <20121022153633.GK2095@tassilo.jf.intel.com>
	 <CAKgNAki=AL+KdYDdYnE8ZhjK-tUf5cZ163BWPe6GRM0rpi-z7w@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mtk.manpages@gmail.com
Cc: Andi Kleen <ak@linux.intel.com>, Andi Kleen <andi@firstfloor.org>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hillf Danton <dhillf@gmail.com>

On Mon, 2012-10-22 at 17:53 +0200, Michael Kerrisk (man-pages) wrote:

> This is all seems to make an awful muck of the API...

 .../...

> There seems to be a reasonable argument here for an mmap3() with a
> 64-bit flags argument...

I tend to agree. There's a similar issue happening when we try to shovel
things into protection bits, like we do with SAO (strong access
ordering) and want to do with per-page endian on embedded.

It think we need a pile of additional flag space.

Cheers,
Ben.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
