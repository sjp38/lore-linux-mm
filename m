Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 9B6536B009F
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 06:52:55 -0400 (EDT)
Date: Mon, 8 Apr 2013 06:52:53 -0400
From: "Frank Ch. Eigler" <fche@redhat.com>
Subject: Re: Excessive stall times on ext4 in 3.9-rc2
Message-ID: <20130408105253.GA5275@redhat.com>
References: <20130402142717.GH32241@suse.de> <20130402150651.GB31577@thunk.org> <20130402151436.GC31577@thunk.org> <20130402181940.GA4936@thunk.org> <y0mwqsehuj9.fsf@fche.csb> <20130408083645.GC2623@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130408083645.GC2623@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Theodore Ts'o <tytso@mit.edu>, linux-ext4@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>

Hi, Mel -

> > [...]  git kernel developers
> > should use git systemtap, as has always been the case.  [...]
> 
> At one point in the past this used to be the case but then systemtap had to
> be compiled as part of automated tests across different kernel versions. It
> could have been worked around in various ways or even installed manually
> when machines were deployed but stap-fix.sh generally took less time to
> keep working.

OK, if that works for you.  Keep in mind though that newer versions of
systemtap retain backward-compatibility for ancient versions of the
kernel, so git systemtap should work on those older versions just
fine.


> [...]
> Yes, this was indeed the problem. The next version of watch-dstate.pl
> treated get_request_wait() as a function that may or may not exist. It
> uses /proc/kallsyms to figure it out.

... or you can use the "?" punctuation in the script to have
systemtap adapt:

    probe kprobe.function("get_request_wait") ?  { ... }


- FChE

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
