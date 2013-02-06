Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 6CF226B0038
	for <linux-mm@kvack.org>; Tue,  5 Feb 2013 21:18:55 -0500 (EST)
Received: by mail-oa0-f44.google.com with SMTP id h1so1001357oag.17
        for <linux-mm@kvack.org>; Tue, 05 Feb 2013 18:18:54 -0800 (PST)
Message-ID: <1360117134.2403.4.camel@kernel.cn.ibm.com>
Subject: Re: [LSF/MM TOPIC] In-kernel compression in the MM subsystem
From: Simon Jeons <simon.jeons@gmail.com>
Date: Tue, 05 Feb 2013 20:18:54 -0600
In-Reply-To: <601542b0-4c92-4d90-aed8-826235c06eab@default>
References: <601542b0-4c92-4d90-aed8-826235c06eab@default>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Konrad Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>

Hi Dan,
On Sat, 2013-01-26 at 12:16 -0800, Dan Magenheimer wrote:
> There's lots of interesting things going on in kernel memory
> management, but one only(?) increases the effective amount
> of data that can be stored in a fixed amount of RAM: in-kernel
> compression.
> 
> Since ramzswap/compcache (now zram) was first proposed in 2009
> as an in-memory compressed swap device, there have been a number
> of in-kernel compression solutions proposed, including
> zcache, kztmem, and now zswap.  Each shows promise to improve
> performance by using compression under memory pressure to
> reduce I/O due to swapping and/or paging.  Each is still
> in staging (though zram may be promoted by LSFMM 2013)
> because each also brings a number of perplexing challenges.
> 
> I think it's time to start converging on which one or more
> of these solutions, if any, should be properly promoted and
> more fully integrated into the kernel memory management
> subsystem.  Before this can occur, it's important to build a
> broader understanding and, hopefully, also a broader consensus
> among the MM community on a number of key challenges and questions
> in order to guide and drive further development and merging.
> 
> I would like to collect a list of issues/questions, and
> start a discussion at LSF/MM by presenting this list, select
> the most important, then lead a discussion on how ever many
> there is time for.  Most likely this is an MM-only discussion
> though a subset might be suitable for a cross-talk presentataion.
> 

Is there benchmark to test each component in tmem?

> Thanks!
> Dan Magenheimer
> LSF/MM attendee 2010,2011,2012
> LSF/MM presenter (MM track) 2011,2012
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
