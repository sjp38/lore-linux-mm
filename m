Received: from fred.muc.de (exim@ns2017.munich.netsurf.de [195.180.232.17])
	by kvack.org (8.8.7/8.8.7) with ESMTP id LAA12886
	for <linux-mm@kvack.org>; Tue, 18 May 1999 11:03:59 -0400
Date: Tue, 18 May 1999 17:04:01 +0200
From: Andi Kleen <ak@muc.de>
Subject: Re: Q: PAGE_CACHE_SIZE?
Message-ID: <19990518170401.A3966@fred.muc.de>
References: <m1yaimzd82.fsf@flinx.ccr.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <m1yaimzd82.fsf@flinx.ccr.net>; from Eric W. Biederman on Tue, May 18, 1999 at 04:03:57PM +0200
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@ccr.net>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 18, 1999 at 04:03:57PM +0200, Eric W. Biederman wrote:
> Who's idea was it start the work to make the granularity of the page
> cache larger?

I guess the main motivation comes from the ARM port, where some versions
have PAGE_SIZE=32k.

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
