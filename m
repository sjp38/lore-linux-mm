Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA01070
	for <linux-mm@kvack.org>; Thu, 26 Nov 1998 17:36:50 -0500
Date: Fri, 27 Nov 1998 17:45:55 GMT
Message-Id: <199811271745.RAA01484@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: Two naive questions and a suggestion
In-Reply-To: <19981126195942.1431.qmail@sidney.remcomp.fr>
References: <Pine.LNX.3.96.981126080204.24048J-100000@mirkwood.dummy.home>
	<19981126195942.1431.qmail@sidney.remcomp.fr>
Sender: owner-linux-mm@kvack.org
To: jfm2@club-internet.fr
Cc: H.H.vanRiel@phys.uu.nl, sct@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On 26 Nov 1998 19:59:42 -0000, jfm2@club-internet.fr said:

> My idea was:

> -VM exhausted and process allocating is a normal process then kill
>  process.
>  -VM exhausted and process is a guaranteed one then kill a non
>  guaranteed process.
> -VM exhausted, process is guaranteed but only remaining processes are
>  guaranteed ones.  Kill allocated process.

But the _whole_ problem is that we do not necessarily go around
killing processes.  We just fail requests for new allocations.  In
that case we still have not run out of memory yet, but a daemon may
have died.  It is simply not possible to guarantee all of the future
memory allocations which a process might make!

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
