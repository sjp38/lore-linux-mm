Subject: Re: memory leakage detection tools
From: Koni <mhw6@cornell.edu>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 25 Jan 2002 14:50:13 -0500
Message-Id: <1011988214.8838.12.camel@abertzale>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: mehul radheshyam choube <mehulchoube_lpsg@rediffmail.com>
Cc: kplug-newbie@kernel-panic.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

You can also try "memprof" -- a gnome app I believe, for visualizing and
tracking memory leaks by using a mark-and-sweep garbage collector to
find allocated chunks that are not referenced anywhere, or something
like that. Worked very well for me on a few items. Sometimes its helpful
to link against debug builds of libraries though as I found sometimes
the stack traces would get messed up without the debugging symbols for
glibc and what not. Only problem with the memprof version I used (it was
a while ago) is I couldn't figure out how to set the command line
arguments for the process I wanted to profile.

Good luck!

Cheers,
Koni

Try "Bounds Checking", a GPL-ed (I believe) program.

 - Neil Fergusson


guy keren wrote:

[snip]

-- 
mhw6@cornell.edu
Koni (Mark Wright)
Solanaceae Genome Network	250 Emerson Hall - Cornell University
Strategic Forecasting		242 Langmuir Laboratory
Lightlink Internet		http://www.lightlink.com/

"If I'm right 90% of the time, why quibble about the other 3%?"

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
