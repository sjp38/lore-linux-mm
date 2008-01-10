Date: Wed, 9 Jan 2008 21:37:21 -0500
From: Rik van Riel <riel@redhat.com>
Subject: Re: [patch 05/19] split LRU lists into anon & file sets
Message-ID: <20080109213721.2ef2e5f3@bree.surriel.com>
In-Reply-To: <20080110112849.d54721ac.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080108205939.323955454@redhat.com>
	<20080108210002.638347207@redhat.com>
	<20080110112849.d54721ac.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Thu, 10 Jan 2008 11:28:49 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> Hmm, it seems..
> 
> When a program copies large amount of files, recent_rotated_file increases
> rapidly and 
> 
>     rotate_sum
>     ----------
> recent_rotated_anon
> 
> will be very big.
> 
> And %ap will be big regardless of vm_swappiness  if it's not 0.
> 
> I think # of recent_successful_pageout(anon/file) should be took into account...
> 
> I'm sorry if I miss something.

You are right.  I wonder if this, again, is a case of myself or
Lee forward porting old code.  I remember having (had) a very
different version of get_scan_ratio() at some point in the past,
but I cannot remember if we discarded this version for that other
version, or the other way around :(

Lee, would you by any chance still have some alternative versions
of get_scan_ratio() around?  I'm searching through my systems, but
have not found it yet...

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
