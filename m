Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA31755
	for <linux-mm@kvack.org>; Wed, 20 Jan 1999 12:10:32 -0500
Date: Wed, 20 Jan 1999 17:09:47 GMT
Message-Id: <199901201709.RAA11707@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: Removing swap lockmap...
In-Reply-To: <Pine.LNX.3.96.990119191333.900A-100000@laser.bogus>
References: <871zksqbyq.fsf@atlas.CARNet.hr>
	<Pine.LNX.3.96.990119191333.900A-100000@laser.bogus>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, "Eric W. Biederman" <ebiederm+eric@ccr.net>, Linux-MM List <linux-mm@kvack.org>, Linux Kernel List <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, 19 Jan 1999 19:15:51 +0100 (CET), Andrea Arcangeli
<andrea@e-mind.com> said:

> On 19 Jan 1999, Zlatko Calusic wrote:
>> Yes, this case probably doesn't get enough testing with my current
>> setup, so it is quite hard (for me) to prove removing lockmap is
>> no-no. Problem is that I don't understand shm swapping very well

> Launch some time this proggy to try out shm swapping:

I have a shared memory stresser anyway if you want.  However, when we
originally took out the lock map, it proved _very_ hard to reproduce the
race, and only a couple of people reported problems.  Plain stress
testing with random access patterns over a day or more did not show up
the problem.  

These races can be very nasty and hard to trigger.  You really do need
to think the change through rather than just try-it-and-see.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
