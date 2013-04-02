Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id EE6916B0002
	for <linux-mm@kvack.org>; Tue,  2 Apr 2013 14:19:44 -0400 (EDT)
Date: Tue, 2 Apr 2013 14:19:40 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: Excessive stall times on ext4 in 3.9-rc2
Message-ID: <20130402181940.GA4936@thunk.org>
References: <20130402142717.GH32241@suse.de>
 <20130402150651.GB31577@thunk.org>
 <20130402151436.GC31577@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130402151436.GC31577@thunk.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, linux-ext4@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>

So I tried to reproduce the problem, and so I installed systemtap
(bleeding edge, since otherwise it won't work with development
kernel), and then rebuilt a kernel with all of the necessary CONFIG
options enabled:

	CONFIG_DEBUG_INFO, CONFIG_KPROBES, CONFIG_RELAY, CONFIG_DEBUG_FS,
	CONFIG_MODULES, CONFIG_MODULE_UNLOAD

I then pulled down mmtests, and tried running watch-dstate.pl, which
is what I sasume you were using, and I got a reminder of why I've
tried very hard to use systemtap:

semantic error: while resolving probe point: identifier 'kprobe' at /tmp/stapdjN4_l:18:7
        source: probe kprobe.function("get_request_wait")
                      ^

semantic error: no match
semantic error: while resolving probe point: identifier 'kprobe' at :74:8
        source: }probe kprobe.function("get_request_wait").return
                       ^

Pass 2: analysis failed.  [man error::pass2]
Unexpected exit of STAP script at ./watch-dstate.pl line 296.

I have no clue what to do next.  Can you give me a hint?

Thanks,

						- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
