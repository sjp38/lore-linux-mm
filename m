Date: Thu, 2 Nov 2000 13:42:25 +0000
From: Malcolm Beattie <mbeattie@sable.ox.ac.uk>
Subject: Re: PATCH [2.4.0test10]: Kiobuf#01, expand IO return codes from iobufs
Message-ID: <20001102134225.D22916@sable.ox.ac.uk>
References: <20001102123400.A1876@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20001102123400.A1876@redhat.com>; from sct@redhat.com on Thu, Nov 02, 2000 at 12:34:00PM +0000
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@nl.linux.org>, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Stephen C. Tweedie writes:
> Kiobuf diff 01: allow for both the errno and the number of bytes
> transferred to be returned in a kiobuf after IO.  We need both in
> order to know how many pages have been dirtied after a failed IO.
[...]
> -	int		errno;		/* Status of completed IO */
> +
> +	/* Equivalent to the return value and "errno" after a syscall: */
> +	int		errno;		/* Error from completed IO (usual
> +					   kernel negative values) */

Although it's nicely commented that errno holds a negative value,
wouldn't it be better to use the usual kernel convention that "err"
holds negative error numbers and "errno" holds positive userland-like
ones? (There are a few places in the kernel which use things called
errno to hold negative numbers but very few). It would just be one
extra little way to help the brain distinguish between the conventions
when using kiobuf and maybe prevent someone beating their head against
a brick wall for a day or two because "if (foo.errno == EIO)" looked
too normal.

--Malcolm

-- 
Malcolm Beattie <mbeattie@sable.ox.ac.uk>
Unix Systems Programmer
Oxford University Computing Services
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
