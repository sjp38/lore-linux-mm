Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA11882
	for <linux-mm@kvack.org>; Sat, 19 Dec 1998 12:11:26 -0500
Date: Sat, 19 Dec 1998 17:10:05 GMT
Message-Id: <199812191710.RAA01252@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: PG_clean for shared mapping smart syncing
In-Reply-To: <Pine.LNX.3.96.981219173054.756A-100000@laser.bogus>
References: <Pine.LNX.3.96.981219172526.648A-100000@laser.bogus>
	<Pine.LNX.3.96.981219173054.756A-100000@laser.bogus>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Sat, 19 Dec 1998 17:37:03 +0100 (CET), Andrea Arcangeli
<andrea@e-mind.com> said:

> Ah but I just found a problem... When we set the PG_clean flag on the page
> we should set the pte readonly for that page in all process vm and not
> only in the process running. But if we must play with the page table it's
> easier to directly set the page as clean as I was used to do with my
> previous update_shared_mappings() patch. So I think we could drop
> completly my last patch and return to my old code and solve the problem to
> handle the mmap_sem locking right...

Agreed, I much prefer the concept of being able to reliably keep the pte
dirty bits consistent between processes.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
