Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id KAA07377
	for <linux-mm@kvack.org>; Wed, 17 Mar 1999 10:48:01 -0500
Date: Wed, 17 Mar 1999 15:47:40 GMT
Message-Id: <199903171547.PAA00908@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: weird calloc problem
In-Reply-To: <199903100151.TAA00665@neumann.ece.iit.edu>
References: <199903100151.TAA00665@neumann.ece.iit.edu>
Sender: owner-linux-mm@kvack.org
To: saraniti@ece.iit.edu
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, 9 Mar 1999 19:51:32 -0600 (EST), marco saraniti
<saraniti@neumann.ece.iit.edu> said:

> I'm having a calloc problem that made me waste three weeks, at this point
> I'm out of options, and I was wondering if this can be a kernel- or
> MM-related problem. Furthermore, the system is a relatively big machine and
> I'd like to share my experience with other people who are interested in
> using Linux for number crunching.

> The problem is trivial: calloc returns a NULL, even if there is a lot
> of free memory. Yes, both arguments of calloc are always > 0.

Do you have any evidence that this is a kernel problem as opposed to a
user-space problem?  A "ps -m" listing of the process concerned when
the fault happens would be useful in pinning this down, as would a
"strace" output.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
