From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14135.28468.394799.280791@dukat.scot.redhat.com>
Date: Tue, 11 May 1999 00:43:48 +0100 (BST)
Subject: Re: [PATCH] dirty pages in memory & co.
In-Reply-To: <Pine.LNX.3.95.990510164506.10344A-100000@as200.spellcast.com>
References: <14135.13698.659905.454361@dukat.scot.redhat.com>
	<Pine.LNX.3.95.990510164506.10344A-100000@as200.spellcast.com>
Sender: owner-linux-mm@kvack.org
To: "Benjamin C.R. LaHaise" <blah@kvack.org>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, "Eric W. Biederman" <ebiederm+eric@ccr.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, 10 May 1999 17:01:50 -0400 (EDT), "Benjamin C.R. LaHaise"
<blah@kvack.org> said:

> Hmmm, it shouldn't be a problem if the write blocks the reading of the
> page and PG_uptodate isn't set.  This conflicts with the current
> assumption in generic_file_read that a locked page becoming unlocked
> without PG_uptodate being set indicates an error -- the best thing here
> is probably to add a PG_error flag and do away with the overloading.

I'm not convinced: doing an explicit read-page and waking up to find it
not uptodate sure sounds like an error to me.  If we find a page which
isn't uptodate, then the first thing we do is try to read it, we don't
generate the error immediately.  Why do we need a new flag?

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
