Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id DBFC76B01B7
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 18:14:48 -0400 (EDT)
Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id o5LMEjdu021159
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 15:14:45 -0700
Received: from pwi7 (pwi7.prod.google.com [10.241.219.7])
	by wpaz21.hot.corp.google.com with ESMTP id o5LMEfDd013247
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 15:14:44 -0700
Received: by pwi7 with SMTP id 7so1789243pwi.28
        for <linux-mm@kvack.org>; Mon, 21 Jun 2010 15:14:41 -0700 (PDT)
Date: Mon, 21 Jun 2010 15:14:32 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: TMPFS permissions bug in 2.6.35-rc3
In-Reply-To: <AANLkTilE0nMsbnkfaQM1vLrSaPeiv5ONgAftI51dQXHO@mail.gmail.com>
Message-ID: <alpine.DEB.1.00.1006211457370.14654@tigran.mtv.corp.google.com>
References: <AANLkTilE0nMsbnkfaQM1vLrSaPeiv5ONgAftI51dQXHO@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Chuck Fox <cfox04@gmail.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Christoph Hellwig <hch@lst.de>, Jiri Slaby <jslaby@suse.cz>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 20 Jun 2010, Chuck Fox wrote:
> 
>    I've encountered a bug in 2.6.35-RC3 where my /tmp directory
> (mounted using tmpfs) returns a "File too large" error when adding
> execute privileges for the group permission byte:
>        Example:
>            touch /tmp/afile
>            chmod 767 /tmp/afile   # example where chmod works fine
> setting bits that are not the group execute bit
>            chmod 755 /tmp/afile
>            chmod: changing permissions of `/tmp/afile': File too large  # bug

How very peculiar!  Thank you for reporting it.  I was about to suggest
some memory corruption must have occurred, but no....

> 
>    There are several gigabytes of free RAM + several more gigabytes of
> swap space available.
> 
>    Here's more information:
> 
> Linux alpha1 2.6.35-rc3-next-20100614 #5 SMP Sun Jun 20 18:55:35 EDT
> 2010 x86_64 Intel(R) Core(TM)2 Duo CPU E8400 @ 3.00GHz GenuineIntel
> GNU/Linux
> ...

... that's actually one of the linux-next kernels you're running there:
and I bet you'll find Jiri's patch below fixes your problem!
