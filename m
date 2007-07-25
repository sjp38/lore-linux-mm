Received: by nz-out-0506.google.com with SMTP id s1so121911nze
        for <linux-mm@kvack.org>; Wed, 25 Jul 2007 03:41:30 -0700 (PDT)
Message-ID: <9a8748490707250341w3fe5a91eoba7c5e8fb6ddc37@mail.gmail.com>
Date: Wed, 25 Jul 2007 12:41:29 +0200
From: "Jesper Juhl" <jesper.juhl@gmail.com>
Subject: Re: -mm merge plans for 2.6.23
In-Reply-To: <46A6E80B.6030704@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070710013152.ef2cd200.akpm@linux-foundation.org>
	 <2c0942db0707232153j3670ef31kae3907dff1a24cb7@mail.gmail.com>
	 <46A58B49.3050508@yahoo.com.au>
	 <2c0942db0707240915h56e007e3l9110e24a065f2e73@mail.gmail.com>
	 <46A6CC56.6040307@yahoo.com.au> <46A6D7D2.4050708@gmail.com>
	 <1185341449.7105.53.camel@perkele> <46A6E1A1.4010508@yahoo.com.au>
	 <Pine.LNX.4.64.0707242252250.2229@asgard.lang.hm>
	 <46A6E80B.6030704@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: david@lang.hm, Eric St-Laurent <ericstl34@sympatico.ca>, Rene Herman <rene.herman@gmail.com>, Ray Lee <ray-lk@madrabbit.org>, Andrew Morton <akpm@linux-foundation.org>, ck list <ck@vds.kolivas.org>, Ingo Molnar <mingo@elte.hu>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 25/07/07, Nick Piggin <nickpiggin@yahoo.com.au> wrote:
[snip]
>
> Well I never said real world tests aren't acceptable, they are. There is
> a difference between an "it feels better for me", and some actual real
> measurement and analysis of said workload.
>

Let me tell you about the use-case where swap prefetch helps me. I
don't have actual numbers currently, only a subjective "it feels
better", but when I get home from work tonight I'll try to collect
some actual numbers for you.

Anyway, here's a description of the scenario (machine is a AMD
Athlon64 X2 4400+, 2GB RAM, 1GB swap, running 32bit kernel &
userspace):

A KDE desktop with the following running is common for me
 - A few (konsole) shells open running vim, pine, less, ssh sessions etc.
 - Eclipse (with CDT) with 20-30 files open in a project.
 - Firefox with 30+ tabs open.
 - LyX with a 200+ page document I'm working on open, is running.
 - Gimp running, usually with at least one or two images open (~1280x1024).
 - Amarok open and playing my playlist (a few days worth of music).
 - At least one Konqueror window in filemanager mode running.
 - More often than not OpenOffice is running with a spreadsheet or
text document open.
 - In the background the machine is running Apache, MySQL, BIND and
NFS services for my local LAN, but they see very little actual use.

Now, a thing I commonly do is fire up a new shell, pull the latest
changes from Linus' git tree and start a script running that builds a
allnoconfig kernel, a allmodconfig kernel, a allyesconfig kernel and
then 30 randconfig kernels.  Obviously that script takes quite a while
to run and loads the box quite a bit, so I usually just leave the box
alone for a few hours until it is done (sometimes I leave it over
night, in which case updatedb also gets added to the mix during the
night). This usually pushes the box to use some amount of swap.

Without swap prefetch; when I start working with one of the apps I had
running before starting the compile job it always feels a little laggy
at first. With swap prefetch app response time is not laggy when I
come back.  The "laggyness" doesn't last too long and is hard to
quantify, but I'll try getting some numbers (if in no other way, then
perhaps by using a stop watch)....

Fact is, this is a scenario that is common to me and one where swap
prefetch definately makes the box feel nicer to work with.


-- 
Jesper Juhl <jesper.juhl@gmail.com>
Don't top-post  http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please      http://www.expita.com/nomime.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
