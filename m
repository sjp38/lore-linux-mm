Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id IAA26396
	for <linux-mm@kvack.org>; Wed, 7 Apr 1999 08:32:56 -0400
Date: Wed, 7 Apr 1999 13:36:23 +0200 (CEST)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: [patch] arca-vm-2.2.5
In-Reply-To: <m1wvzpvxbp.fsf@flinx.ccr.net>
Message-ID: <Pine.LNX.4.05.9904071332070.818-100000@laser.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@ccr.net>
Cc: Chuck Lever <cel@monkey.org>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 7 Apr 1999, Eric W. Biederman wrote:

>#define __l1_cache_aligned __attribute__((aligned (L1_CACHE_BYTES)))
>...
>
>}
>#ifdef SMP
>__l1_cache_aligned
>#endif
>mem_map_t;
>
>Looks even better, and is even maintainable.

Agreed should work fine, but I think gcc-2.7.2.3 is not able to 32bit
align (why?? and could somebody confirm or invalidate that?). Here
egcs-1.1.1 32bit align the fragment fine (tried in userspace now).

Thanks.

Andrea Arcangeli

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
