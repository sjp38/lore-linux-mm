Date: Wed, 6 Sep 2000 09:33:57 +0100 (BST)
From: Mark Hemment <markhe@veritas.com>
Subject: Re: stack overflow
In-Reply-To: <20000905190334.4067.qmail@web6403.mail.yahoo.com>
Message-ID: <Pine.LNX.4.21.0009060931580.15193-100000@alloc>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Zeshan Ahmad <zeshan_uet@yahoo.com>
Cc: tigran@veritas.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Zeshan,

  What version of 2.2.x are you using, and have you applied any patches it
to?
  I'm not subscribed to linux-mm at the moment, so I missed your original
posting.

Mark


On Tue, 5 Sep 2000, Zeshan Ahmad wrote:

> Hi
> 
> I have figured out why the patch is'nt working. 
> 
> Mark wrote:
> >In my original, the code assumes that all general
> >purpose slabs below
> >"bufctl_limit" where suitable for bufctl allocation 
> >(look at a 2.2.x
> >version, in kmem_cache_sizes_init() I have a state
> >variable called
> >"found").
>   
> Since I am already using 2.2.x, so the patch is not
> working. This means i am already using the variable
> "found".
> So this will not work i presume.
> 
> Any other solution available?
> 
> Regards
> Zeshan
> 
> __________________________________________________
> Do You Yahoo!?
> Yahoo! Mail - Free email you can access from anywhere!
> http://mail.yahoo.com/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
