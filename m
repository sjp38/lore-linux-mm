Date: Tue, 03 Dec 2002 12:08:09 -0800
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: [PATCH] 2.4.20-rmap15a
Message-ID: <30200000.1038946087@titus>
In-Reply-To: <20021203195854.GA6709@zork.net>
References: <Pine.LNX.4.44L.0212011833310.15981-100000@imladris.surriel.com>
 <6usmxfys45.fsf@zork.zork.net> <20021203195854.GA6709@zork.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: The One True Dave Barry <dave@zork.net>, linux-mm@kvack.org
Cc: sneakums@zork.net
List-ID: <linux-mm.kvack.org>

> 	This is correct, and believe it or not i'm even using
> 	2.4.19 + rmap15a, no other patches.  I don't have my hard
> 	numbers available, but the difference between builds was quite
> 	significant, something like:
>
> 	2.4.19 vanilla:
> 	real 85m
>
> 	2.4.19-rmap15a:
> 	real 102m

Assuming the extra time is eaten in Sys, not User, can you get a profile
of each, & post them?

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
