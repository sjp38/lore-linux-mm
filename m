Date: Sat, 1 Feb 2003 02:00:01 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: hugepage patches
Message-ID: <20030201100001.GC29981@holomorphy.com>
References: <20030131151501.7273a9bf.akpm@digeo.com> <20030131151858.6e9cc35e.akpm@digeo.com> <20030201095848.C789@nightmaster.csn.tu-chemnitz.de> <20030201013136.312a946d.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030201013136.312a946d.akpm@digeo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Feb 01, 2003 at 01:31:36AM -0800, Andrew Morton wrote:
> Well I'm thinking of renaming it to hugebugfs.  It should be settled down
> shortly.

We've had a difference of opinion wrt. the proper mechanism for
referring things to the head of their superpage. I guess in one
sense I could be blamed for not following directions, but I _really_
didn't want to go in the direction of killing ->lru for all time.

There is also other shite I'd _really_ rather not get into publicly.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
