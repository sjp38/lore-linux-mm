Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 13B536B0005
	for <linux-mm@kvack.org>; Sat, 26 Jan 2013 15:16:20 -0500 (EST)
MIME-Version: 1.0
Message-ID: <601542b0-4c92-4d90-aed8-826235c06eab@default>
Date: Sat, 26 Jan 2013 12:16:11 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: [LSF/MM TOPIC] In-kernel compression in the MM subsystem
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org
Cc: linux-mm@kvack.org, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Konrad Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>

There's lots of interesting things going on in kernel memory
management, but one only(?) increases the effective amount
of data that can be stored in a fixed amount of RAM: in-kernel
compression.

Since ramzswap/compcache (now zram) was first proposed in 2009
as an in-memory compressed swap device, there have been a number
of in-kernel compression solutions proposed, including
zcache, kztmem, and now zswap.  Each shows promise to improve
performance by using compression under memory pressure to
reduce I/O due to swapping and/or paging.  Each is still
in staging (though zram may be promoted by LSFMM 2013)
because each also brings a number of perplexing challenges.

I think it's time to start converging on which one or more
of these solutions, if any, should be properly promoted and
more fully integrated into the kernel memory management
subsystem.  Before this can occur, it's important to build a
broader understanding and, hopefully, also a broader consensus
among the MM community on a number of key challenges and questions
in order to guide and drive further development and merging.

I would like to collect a list of issues/questions, and
start a discussion at LSF/MM by presenting this list, select
the most important, then lead a discussion on how ever many
there is time for.  Most likely this is an MM-only discussion
though a subset might be suitable for a cross-talk presentataion.

Thanks!
Dan Magenheimer
LSF/MM attendee 2010,2011,2012
LSF/MM presenter (MM track) 2011,2012


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
