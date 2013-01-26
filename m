Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 6FEC06B0012
	for <linux-mm@kvack.org>; Sat, 26 Jan 2013 10:43:49 -0500 (EST)
Date: Sat, 26 Jan 2013 10:43:40 -0500
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [PATCH] Subtract min_free_kbytes from dirtyable memory
Message-ID: <20130126154340.GC5887@thunk.org>
References: <1359118913.3146.3.camel@deadeye.wl.decadent.org.uk>
 <201301252349.r0PNnFYF024399@como.maths.usyd.edu.au>
 <20130126001419.GG3341@elie.Belkin>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130126001419.GG3341@elie.Belkin>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Nieder <jrnieder@gmail.com>
Cc: paul.szabo@sydney.edu.au, 695182@bugs.debian.org, ben@decadent.org.uk, linux-kernel@vger.kernel.org, linux-mm@kvack.org, minchan@kernel.org

(In the teach a person to fish category...)

If you know the file and line number where a bug/regression was
introduced, the "git blame" command is a great tool for identifying
the commit which changed a given line of code.  Then use "git tag
--contains <commit it>" to see when a particular commit was introduced
into the mainline kernel.

					- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
