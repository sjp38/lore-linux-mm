Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA06941
	for <linux-mm@kvack.org>; Thu, 20 May 1999 13:25:07 -0400
Date: Thu, 20 May 1999 19:12:14 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: Q: PAGE_CACHE_SIZE?
In-Reply-To: <19990518170401.A3966@fred.muc.de>
Message-ID: <Pine.LNX.4.05.9905201904370.3038-100000@laser.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <ak@muc.de>
Cc: "Eric W. Biederman" <ebiederm+eric@ccr.net>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 18 May 1999, Andi Kleen wrote:

>On Tue, May 18, 1999 at 04:03:57PM +0200, Eric W. Biederman wrote:
>> Who's idea was it start the work to make the granularity of the page
>> cache larger?
>
>I guess the main motivation comes from the ARM port, where some versions
>have PAGE_SIZE=32k.

Since they have a too much large PAGE_SIZE, they shouldn't be interested
in enalrging the page-cache-size.

Andrea Arcangeli

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
