Date: Tue, 21 Jan 2003 09:03:52 -0500 (EST)
From: Bill Davidsen <davidsen@tmr.com>
Subject: Re: 2.5.59-mm1
In-Reply-To: <20030117002451.69f1eda1.akpm@digeo.com>
Message-ID: <Pine.LNX.3.96.1030121085913.30318A-100000@gatekeeper.tmr.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 17 Jan 2003, Andrew Morton wrote:

> http://www.zip.com.au/~akpm/linux/patches/2.5/2.5.59/2.5.59-mm1/

> -rcf.patch
> 
>  run-child-first didn't seem to help anything, and an alarming number of
>  cleanups and fixes were needed to get it working right.  Later.

I don't know about right, it seems to make threaded applications
originally developed on BSD work better (much lower context switching).
Anyone know if BSD does rcf? This may be an artifact of...

> +ext3-scheduling-storm.patch
> 
>  Fix the bug wherein ext3 sometimes shows blips of 100k context
>  switches/sec.

Is this a 2.5 bug only? Does this need to be back ported to 2.4? Perhaps
this is why I have ctx rate problems and some other sites don't with a
certain application. Very commercial, unfortunately.

-- 
bill davidsen <davidsen@tmr.com>
  CTO, TMR Associates, Inc
Doing interesting things with little computers since 1979.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
