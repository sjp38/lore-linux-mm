Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 748806B012F
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 19:16:40 -0400 (EDT)
Date: Fri, 5 Apr 2013 19:16:35 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: Excessive stall times on ext4 in 3.9-rc2
Message-ID: <20130405231635.GA6521@thunk.org>
References: <20130402142717.GH32241@suse.de>
 <20130402150651.GB31577@thunk.org>
 <20130402151436.GC31577@thunk.org>
 <20130403101925.GA7341@suse.de>
 <515F4DA3.2000000@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <515F4DA3.2000000@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Slaby <jslaby@suse.cz>
Cc: Mel Gorman <mgorman@suse.de>, linux-ext4@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Sat, Apr 06, 2013 at 12:18:11AM +0200, Jiri Slaby wrote:
> Ok, so now I'm runnning 3.9.0-rc5-next-20130404, it's not that bad, but
> it still sucks. Updating a kernel in a VM still results in "Your system
> is too SLOW to play this!" by mplayer and frame dropping.

What was the first kernel where you didn't have the problem?  Were you
using the 3.8 kernel earlier, and did you see the interactivity
problems there?

What else was running in on your desktop at the same time?  How was
the file system mounted, and can you send me the output of dumpe2fs -h
/dev/XXX?  Oh, and what options were you using to when you kicked off
the VM?

The other thing that would be useful was to enable the jbd2_run_stats
tracepoint and to send the output of the trace log when you notice the
interactivity problems.

Thanks,

						- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
