Received: from atlas.CARNet.hr (zcalusic@atlas.CARNet.hr [161.53.123.163])
	by kvack.org (8.8.7/8.8.7) with ESMTP id LAA16245
	for <linux-mm@kvack.org>; Thu, 31 Dec 1998 11:54:05 -0500
Subject: Re: Swap File improvement.
References: <m1n24crn4l.fsf@flinx.ccr.net>
Reply-To: Zlatko.Calusic@CARNet.hr
From: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Date: 31 Dec 1998 17:53:15 +0100
In-Reply-To: ebiederm+eric@ccr.net's message of "25 Dec 1998 14:18:50 -0600"
Message-ID: <87af04l0ck.fsf@atlas.CARNet.hr>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@ccr.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Eric wrote:
> The following patch allows asynchronous swapping to swap files,
> improving their performance immensely.
> 
> Additionally since now all swapping goes there brw_page, the semantics are much
> cleaner, and we don't need to maintain ll_rw_swap_file.

Great!

I tested your changes in 2.2.0-pre1 and I'm astonished with a
performance change.

Before, swap files (unlike swap partitions) were not usable at all,
that is, speed was abysmal. With your changes swap files now perform
at about 80% of swap partition performance, exactly as I was
expecting.

Very good work, indeed.

Happy New Year to you and yours!

Happy New 1999. to all the Linux hackers!
-- 
Zlatko
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
