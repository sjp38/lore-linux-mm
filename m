Received: from dax.scot.redhat.com (dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA14613
	for <linux-mm@kvack.org>; Mon, 23 Nov 1998 13:10:03 -0500
Date: Mon, 23 Nov 1998 18:08:59 GMT
Message-Id: <199811231808.SAA21383@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: Two naive questions and a suggestion
In-Reply-To: <19981119002037.1785.qmail@sidney.remcomp.fr>
References: <19981119002037.1785.qmail@sidney.remcomp.fr>
Sender: owner-linux-mm@kvack.org
To: jfm2@club-internet.fr
Cc: linux-mm@kvack.org, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On 19 Nov 1998 00:20:37 -0000, jfm2@club-internet.fr said:

> 1) Is there any text describing memory management in 2.1?  (Forgive me
>    if I missed an obvious URL)

The source code. :)

> 2) Are there plans for implementing the swapping of whole processes a
>    la BSD?

Not exactly, but there are substantial plans for other related changes.
In particular, most of the benefits of BSD-style swapping can be
achieved through swapping of page tables, dynamic RSS limits and
streaming swapout, all of which are on the slate for 2.3.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
