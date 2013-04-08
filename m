Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 077116B00A4
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 07:01:16 -0400 (EDT)
Date: Mon, 8 Apr 2013 07:01:12 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: Excessive stall times on ext4 in 3.9-rc2
Message-ID: <20130408110112.GA8332@thunk.org>
References: <20130402142717.GH32241@suse.de>
 <20130402150651.GB31577@thunk.org>
 <20130402151436.GC31577@thunk.org>
 <20130402181940.GA4936@thunk.org>
 <y0mwqsehuj9.fsf@fche.csb>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <y0mwqsehuj9.fsf@fche.csb>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Frank Ch. Eigler" <fche@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>, linux-ext4@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>

On Sun, Apr 07, 2013 at 05:59:06PM -0400, Frank Ch. Eigler wrote:
> > semantic error: while resolving probe point: identifier 'kprobe' at /tmp/stapdjN4_l:18:7
> >         source: probe kprobe.function("get_request_wait")
> >                       ^
> > Pass 2: analysis failed.  [man error::pass2]
> > Unexpected exit of STAP script at ./watch-dstate.pl line 296.
> > I have no clue what to do next.  Can you give me a hint?

Is there any reason why the error message couldn't be simplified, to
something as "kernel symbol not found"?  I wasn't sure if the problem
was that there was some incompatibility between a recent change with
kprobe and systemtap, or parse failure in the systemtap script, etc.

> Systemtap could endavour to list roughly-matching functions that do
> exist, if you think that's be helpful.

If the goal is ease of use, I suspect the more important thing that
systemtap could do is to make its error messages more easily
understandable, instead of pointing the user to read a man page where
the user then has to figure out which one of a number of failure
scenarios were caused by a particularly opaque error message.  (The
man page doesn't even say that "semantic error while resolving probe
point" means that a kernel function doesn't exist -- especially
complaining about the kprobe identifier points the user in the wrong
direction.)

							- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
