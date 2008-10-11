From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [rfc] approach to pull writepage out of reclaim
Date: Sat, 11 Oct 2008 15:13:22 +1100
References: <20081009144103.GE9941@wotan.suse.de> <20081010162103.7c8b61c0.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081010162103.7c8b61c0.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Disposition: inline
Message-Id: <200810111513.22873.nickpiggin@yahoo.com.au>
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Friday 10 October 2008 18:21, KAMEZAWA Hiroyuki wrote:
> On Thu, 9 Oct 2008 16:41:03 +0200
>
> Nick Piggin <npiggin@suse.de> wrote:
> > Hi,
> >
> > Just got bored of looking at other things, and started coding up the
> > first step to remove writepage from vmscan.
>
> Can I make a question ? Is this "vmscan" here means
>
>   - direct memory reclaim triggered by memory allocation failure
> (alloc_pages()) and not
>   - kswapd
>   - memory resource controller hits its limit
>
> or including all memory reclaim path ?

Anywhere that we writeout from LRUs (as opposed to from the inode).
That probably includes all of the above.

Actually, probably my first patch is not so critical. We can probably
start by just special casing writepage for the swapout path, and then
the writepage for filesystems becomes a slowpath which can do the
extra locking and refcounting...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
