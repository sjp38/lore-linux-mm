Date: Fri, 6 Sep 2002 11:57:03 -0700 (MST)
From: Craig Kulesa <ckulesa@as.arizona.edu>
Subject: Re: slablru for 2.5.32-mm1
In-Reply-To: <200209060739.27058.tomlins@cam.org>
Message-ID: <Pine.LNX.4.44.0209061147450.31279-100000@loke.as.arizona.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ed Tomlinson <tomlins@cam.org>
Cc: Andrew Morton <akpm@zip.com.au>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 6 Sep 2002, Ed Tomlinson wrote:

> The bottom line is that slablru is getting rewritten.  

Okay -- sounds quite interesting.  Be glad to test it. :)

> Do you have the BUGON changes in a patch all by themselves?

Sure do, against 2.5.33 vanilla. 
http://loke.as.arizona.edu/~ckulesa/kernel/rmap-vm/2.5.33/BUG_ONification

fs/dcache.c |   11 ++---
fs/dquot.c  |    3 -
fs/inode.c  |   18 +++------
mm/slab.c   |  117 ++++++++++++++++++++--------------------------------------
4 files changed, 54 insertions(+), 95 deletions(-)

Cheers,
Craig Kulesa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
