Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id JAA00041
	for <linux-mm@kvack.org>; Tue, 21 Jan 2003 09:27:55 -0800 (PST)
Date: Tue, 21 Jan 2003 09:27:54 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: 2.5.59-mm1
Message-Id: <20030121092754.146e64ff.akpm@digeo.com>
In-Reply-To: <Pine.LNX.3.96.1030121085913.30318A-100000@gatekeeper.tmr.com>
References: <20030117002451.69f1eda1.akpm@digeo.com>
	<Pine.LNX.3.96.1030121085913.30318A-100000@gatekeeper.tmr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Bill Davidsen <davidsen@tmr.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Bill Davidsen <davidsen@tmr.com> wrote:
>
> On Fri, 17 Jan 2003, Andrew Morton wrote:
> 
> > http://www.zip.com.au/~akpm/linux/patches/2.5/2.5.59/2.5.59-mm1/
> 
> > -rcf.patch
> > 
> >  run-child-first didn't seem to help anything, and an alarming number of
> >  cleanups and fixes were needed to get it working right.  Later.
> 
> I don't know about right, it seems to make threaded applications
> originally developed on BSD work better (much lower context switching).
> Anyone know if BSD does rcf? This may be an artifact of...

"seems to make"?  This is too vague for me to comment on, unfortunately.

What applications?  What measurements have been made?

It can only affect creation of new threads, not the switching between extant
ones.

> > +ext3-scheduling-storm.patch
> > 
> >  Fix the bug wherein ext3 sometimes shows blips of 100k context
> >  switches/sec.
> 
> Is this a 2.5 bug only? Does this need to be back ported to 2.4? Perhaps
> this is why I have ctx rate problems and some other sites don't with a
> certain application. Very commercial, unfortunately.
> 

The problem has existed in 2.4 since 2.4.20-pre5.  The context switch
problem will only exhibit for small periods of time (say, 10's to 100's of
milliseconds) when the filesystem is under heavy write load.

A patch for 2.4 is at

http://www.zip.com.au/~akpm/linux/patches/2.4/2.4.20/ext3-scheduling-storm.patch
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
