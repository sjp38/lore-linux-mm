Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 6E1286B01EE
	for <linux-mm@kvack.org>; Mon, 12 Apr 2010 03:51:41 -0400 (EDT)
Message-ID: <4BC2D0C9.3060201@redhat.com>
Date: Mon, 12 Apr 2010 10:50:33 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
References: <20100410184750.GJ5708@random.random> <20100410190233.GA30882@elte.hu> <4BC0CFF4.5000207@redhat.com> <20100410194751.GA23751@elte.hu> <4BC0DE84.3090305@redhat.com> <20100411104608.GA12828@elte.hu> <4BC1B2CA.8050208@redhat.com> <20100411120800.GC10952@elte.hu> <20100412060931.GP5683@laptop> <20100412070811.GD5656@random.random> <20100412072144.GS5683@laptop>
In-Reply-To: <20100412072144.GS5683@laptop>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@elte.hu>, Mike Galbraith <efault@gmx.de>, Jason Garrett-Glaser <darkshikari@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On 04/12/2010 10:21 AM, Nick Piggin wrote:
>>
>> All data I provided is very real, in addition to building a ton of
>> packages and running emerge on /usr/portage I've been running all my
>> real loads. Only problem I only run it for 1 day and half, but the
>> load I kept it under was significant (surely a lot bigger inode/dentry
>> load that any hypervisor usage would ever generate).
>>      
> OK, but as a solution for some kind of very specific and highly
> optimized application already like RDBMS, HPC, hypervisor or JVM,
> they could just be using hugepages themselves, couldn't they?
>
> It seems more interesting as a more general speedup for applications
> that can't afford such optimizations? (eg. the common case for
> most people)
>    

The problem with hugetlbfs is that you need to commit upfront to using 
it, and that you need to be the admin.  For virtualization, you want to 
use hugepages when there is no memory pressure, but you want to use ksm, 
ballooning, and swapping when there is (and then go back to large pages 
when pressure is relieved, e.g. by live migration).

HPC and databases can probably live with hugetlbfs.  JVM is somewhere in 
the middle, they do allocate memory dynamically.


-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
