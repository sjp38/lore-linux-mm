Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id IAA09601
	for <linux-mm@kvack.org>; Sun, 29 Sep 2002 08:47:56 -0700 (PDT)
Message-ID: <3D9720AB.BB226D58@digeo.com>
Date: Sun, 29 Sep 2002 08:47:55 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: [PATCH] add callback back to slab pruning
References: <20020928234930.F13817@bitchcake.off.net> <3D968652.28AD6766@digeo.com> <200209290931.29653.tomlins@cam.org>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ed Tomlinson <tomlins@cam.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ed Tomlinson wrote:
> 
> Hi Andrew,
> 
> I posted this Thursday but it seems to have gotten lost in
> the storm of messages on slab.
> 

Ah, sorry, I neglected to answer.  Yes, I have been testing
this for a few days, works fine thanks.

Calling out to the shrinker to find out how many objects
they have is sneaky.

I haven't looked super-closely at the code, but it'd be nice
to make shrinker_lock go away ;)
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
