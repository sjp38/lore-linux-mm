Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 1F7056B009E
	for <linux-mm@kvack.org>; Tue, 26 Jan 2010 12:10:11 -0500 (EST)
Message-ID: <4B5F21D4.1090305@redhat.com>
Date: Tue, 26 Jan 2010 19:09:40 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 00 of 30] Transparent Hugepage support #3
References: <patchbomb.1264054824@v2.random> <alpine.DEB.2.00.1001220845000.2704@router.home> <20100122151947.GA3690@random.random> <alpine.DEB.2.00.1001221008360.4176@router.home> <20100123175847.GC6494@random.random> <alpine.DEB.2.00.1001251529070.5379@router.home> <20100125224643.GA30452@random.random> <alpine.DEB.2.00.1001260939050.23549@router.home> <20100126161120.GN30452@random.random> <alpine.DEB.2.00.1001261022480.25184@router.home>
In-Reply-To: <alpine.DEB.2.00.1001261022480.25184@router.home>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On 01/26/2010 06:30 PM, Christoph Lameter wrote:
> On Tue, 26 Jan 2010, Andrea Arcangeli wrote:
>    
>> No. O_DIRECT already works on those pages without splitting them,
>> there is no need to split them, just run 512 gups like you would be
>> doing if those weren't hugepages.
>>      
> That show the scaling issue is not solved.
>    

Well, gup works for a range of addresses, so all you need it one, and 
I'm sure it can be optimized to take advantage of transparent huge pages.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
