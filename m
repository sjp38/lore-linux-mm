Received: from flinx.npwt.net (eric@flinx.npwt.net [208.236.161.237])
	by kvack.org (8.8.7/8.8.7) with ESMTP id QAA20285
	for <linux-mm@kvack.org>; Fri, 19 Jun 1998 16:31:10 -0400
Subject: Re: New Linux-MM homepage
References: <Pine.LNX.3.96.980619190100.7276A-100000@mirkwood.dummy.home>
From: ebiederm+eric@npwt.net (Eric W. Biederman)
Date: 19 Jun 1998 14:29:51 -0500
In-Reply-To: Rik van Riel's message of Fri, 19 Jun 1998 19:06:08 +0200 (CEST)
Message-ID: <m1g1h1w5ow.fsf@flinx.npwt.net>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: "Eric W. Biederman" <ebiederm+eric@npwt.net>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

>>>>> "RR" == Rik van Riel <H.H.vanRiel@phys.uu.nl> writes:

RR> On 19 Jun 1998, Eric W. Biederman wrote:

RR> Well, there are several cases where we 'forget' about
RR> shared area's. One of them is where SysV shared memory
RR> is unmapped from all processes but the handle remains.
RR> Since we do page scanning by process, we can't find
RR> such an area. I don't know if this has been fixed by
RR> now, but I certainly remember the messages about it...

I hadn't quite categorized it that way.  
But I both discovered the problem and have posted a fix to linux-mm
that should work.

So for that case of swapoff we are fine.  Or should be soon :)
Now if there are any other cases I don't know about.

I was afraid you were talking about a memory leak...

Eric
