Date: Thu, 19 May 2005 10:43:25 +0900 (JST)
Message-Id: <20050519.104325.13596447.taka@valinux.co.jp>
Subject: Re: [PATCH 0/6] CKRM: Memory controller for CKRM
From: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <20050519003008.GC25076@chandralinux.beaverton.ibm.com>
References: <20050519003008.GC25076@chandralinux.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: sekharan@us.ibm.com
Cc: ckrm-tech@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

It just looks like that once kswapd moves pages between the active lists
and the inactive lists, the pages happen to belong to the class
to which kswapd belong.

Is this right behavior that you intend?

> Hello ckrm-tech members,
> 
> Here is the latest CKRM Memory controller patch against the patchset Gerrit
> released on 05/05/05.
> 
> I applied the feedback I got on/off the list. Made few fixes and some
> cleanups. Details about the changes are in the appripriate patches.
> 
> It is tested on i386.
> 
> Currently disabled on NUMA.
> 
> Hello linux-mm members,
> 
> These are set of patches that provides the control of memory under the CKRM
> framework(Details at http://ckrm.sf.net). I eagerly wait for your
> feedback/comments/suggestions/concerns etc.,
> 
> To All,
> 
> I am looking for improvement suggestions
>         - to not have a field in the page data structure for the mem
>           controller

What do you think if you make each class owns inodes instead of pages
in the page-cache?

> 	- to make vmscan.c cleaner.


Thanks,
Hirokazu Takahashi.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
