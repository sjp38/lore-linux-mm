Received: from pop01.globecomm.net (pop01.globecomm.net [206.253.129.185])
	by kvack.org (8.8.7/8.8.7) with ESMTP id CAA17347
	for <linux-mm@kvack.org>; Fri, 21 Aug 1998 02:21:15 -0400
Date: Thu, 20 Aug 1998 23:20:27 -0700 (MST)
From: Adam Fritzler <afritz@iname.com>
Subject: Re: memory use in Linux
In-Reply-To: <3.0.3.32.19980820223733.006b4b5c@valemount.com>
Message-ID: <Pine.BSI.3.96.980820231214.5550A-100000@usr01.primenet.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Lonnie Nunweiler <lonnie@valemount.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


I'm no where near on expert, but the "free memory is wasted memory" has
been used for far longer than just Linux, and AFAIK has been the policy
for most if not all UNIX variants.

Why your machine didn't stay up for more than 3 days does not sound like a
memory managemnt issue in the kernel.  I would guess you had a leaky
userspace process.  Although some kernels have memory leaks, I don't
remember any of them being quite that bad.  Also, I don't understand the
relationship between running out of memory and corrupt files.  

Many, many people (including myself) have Linux machines running the same
services as you describe in far, far less RAM and have uptimes of many
months, and absolutly no corrupt files.

I'll leave the scrambling-to-free-caches issue to the more knowlegable, as
I see your reasons of justification of leaving memory free as more
justification of the current policy than anything else.  When you put
money in the bank, do you not get paid interest?  This is like using a
checking account instead of a savings account for idle moneys!

af

On Thu, 20 Aug 1998, Lonnie Nunweiler wrote:

> I am researching why Linux runs into memory problems.  We recently had to
> convert our dialin server, email and web server to NT, because the Linux
> machine would eventually eat up all ram, and then crash.  We were using
> 128MB machines, and it would take about 3 days before rebooting was
> required.  If we didn't reboot soon enough, it was a very messy job
> rebuilding some of the chewed files.
> 
> I have encountered the saying "free memory is wasted memory", and it got me
> thinking.  I believe that statement is completely wrong, and is responsible
> for the current problems that Linux is having for systems that keep running
> (servers) as opposed to systems that get shut down nightly.
> 
> If we were to treat memory as money, we would not think that money sitting
> idly in the bank is wasted.  I've been there, with no reserves, and it is
> not fun.  If too much is sitting idle, it might not be best, but let it
> sit.  It is ready in an instant should we need it.  If it is not there when
> we need it, we scramble, and sometimes get embarrassed.
> 
> I think the memory manager should place limits on caching, so as to leave a
> specified amount of free ram.
> 
> >From what I have observed, processes will eventually use up all available
> ram, and get into swapping.  Imagine having a buddy or partner that was
> just following you around to get any money you earned, and immediately
> spent it.  Eventually important things would be delayed until you could get
> enough put aside to cover them.....only problem, that buddy is grabbing
> anything you put away, and spending it.  You try as hard as you wish, but,
> no way can you get ahead.  Then total disaster strikes.  Your partner has
> gotten hold of a credit card.  At this point you can forget about ever
> having anything to spare.  Time to reboot.
> 
> It's silly to have a 64M machine, running only a primary DNS task, and
> having it slowly get its memory chewed up, and then get into swapping.
> When it crashes due to no available memory, what was gained in a few
> milliseconds faster disk access because of caching?
> 
> Is it possible to configure Linux to limit the performance speeder-uppers
> to leave a specified chunk of ram available?  Do you think this would help
> with reliability?  Can anyone tell me how to do it?
> 
> Thanks
> Lonnie Nunweiler, President
> WebWorld Warehouse Ltd.
> 1255 - 5 th Ave.
> PO Box 1030
> Valemount, BC.  V0E 2Z0
> 
> www.valemount.com
> www.webworldwarehouse.com
> 
> lonnie@valemount.com
> lonnie@vis.bc.ca
> Voice: (250) 566-4698  Fax: (250) 566-9835
> 
> --
> This is a majordomo managed list.  To unsubscribe, send a message with
> the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
> 




-------------------------------------------------------------------------------
Adam Fritzler                           |
  afritz@delphid.ml.org                 | Animals who are not penguins can   
    afritz@iname.com                    |    can only wish they were.
      http://delphid.ml.org/~afritz/    |        -- Chicago Reader 
        http://www.pst.com/             |               15 Oct 1982
-------------------------------------------------------------------------------

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
