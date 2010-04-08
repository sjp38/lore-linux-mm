Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 9135C600337
	for <linux-mm@kvack.org>; Thu,  8 Apr 2010 11:27:56 -0400 (EDT)
Message-ID: <4BBDF5CA.5050907@redhat.com>
Date: Thu, 08 Apr 2010 18:27:06 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 00 of 67] Transparent Hugepage Support #18
References: <patchbomb.1270691443@v2.random> <4BBDA43F.5030309@redhat.com> <4BBDC181.5040205@redhat.com> <20100408152302.GA5749@random.random>
In-Reply-To: <20100408152302.GA5749@random.random>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On 04/08/2010 06:23 PM, Andrea Arcangeli wrote:
> On Thu, Apr 08, 2010 at 02:44:01PM +0300, Avi Kivity wrote:
>    
>> Results here are less than stellar.  While khugepaged is pulling pages
>> together, something is breaking them apart.  Even after memory pressure
>> is removed, this behaviour continues.  Can it be that compaction is
>> tearing down huge pages?
>>      
> migrate will split hugepages, but memory compaction shouldn't migrate
> hugepages... If it does I agree it needs fixing.
>
>    

Well, khugepaged was certainly fighting with something.  Perhaps ftrace 
will point the finger.

> At the moment the main problem I'm having is that only way to run
> stable for me is to stop at patch 48 (included). So it's something
> wrong with memory compaction or migrate.
>    

It ran stably for me FWIW.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
