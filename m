Received: from imperial.edgeglobal.com (imperial.edgeglobal.com [208.197.226.14])
	by edgeglobal.com (8.9.1/8.9.1) with ESMTP id LAA21035
	for <linux-mm@kvack.org>; Sun, 19 Sep 1999 11:07:14 -0400
Date: Sun, 19 Sep 1999 11:13:05 -0400 (EDT)
From: James Simmons <jsimmons@edgeglobal.com>
Subject: Re: Need ammo against BSD Fud
In-Reply-To: <Pine.LNX.4.10.9909191427000.22068-100000@mirkwood.dummy.home>
Message-ID: <Pine.LNX.4.10.9909191106030.26343-100000@imperial.edgeglobal.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 19 Sep 1999, Rik van Riel wrote:

> On Fri, 17 Sep 1999, JF Martinez wrote:
> 
> > BSD people are writing tons of articles saying how superior BSD is
> > respective to Linux.  There is a danger they will impregnate
> > people with the idea: Linux=second rate system.
> 
> The BSD VM system _is_ better than the Linux one, but AFAIK
> that's about the only part where we lag in such a way that
> people can actually notice a difference.
> 
> I think it's time to stop the advocacy and start the design
> of a better Linux VM system. The first part would be a real
> zoned memory allocator. More in my next mail...

We need to worry about making a better kernel. I don't know
nothing about BSD VM svs linux  VM but I do know linux needs a more
uniform  resource manager to make module writing easier. Having things
like write_b  vary from platform to platform makes life a real nightmare
for module writers. Also thier is a real lack of docs on how to make
drivers portable to all platforms. Of course this will be tackled in
2.5.x. 




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
