Received: from alogconduit1ah.ccr.net (ccr@alogconduit1ah.ccr.net [208.130.159.8])
	by kvack.org (8.8.7/8.8.7) with ESMTP id BAA22897
	for <linux-mm@kvack.org>; Wed, 7 Apr 1999 01:33:51 -0400
Subject: Re: [patch] arca-vm-2.2.5
References: <Pine.LNX.4.05.9904062119441.1277-100000@laser.random>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 07 Apr 1999 00:00:58 -0500
In-Reply-To: Andrea Arcangeli's message of "Tue, 6 Apr 1999 22:26:20 +0200 (CEST)"
Message-ID: <m1wvzpvxbp.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: Chuck Lever <cel@monkey.org>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "AA" == Andrea Arcangeli <andrea@e-mind.com> writes:

AA> Does something like this looks like better?
yes. But:

#define __l1_cache_aligned __attribute__((aligned (L1_CACHE_BYTES)))
...

}
#ifdef SMP
__l1_cache_aligned
#endif
mem_map_t;

Looks even better, and is even maintainable.
Note: I haven't tried actually tried to compile this fragment ...

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
