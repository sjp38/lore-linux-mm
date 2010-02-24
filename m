Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 9D5626B0047
	for <linux-mm@kvack.org>; Wed, 24 Feb 2010 16:59:26 -0500 (EST)
Date: Wed, 24 Feb 2010 22:58:25 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [patch 36/36] khugepaged
Message-ID: <20100224215825.GF29956@random.random>
References: <20100221141009.581909647@redhat.com>
 <20100221141758.658303189@redhat.com>
 <20100224121111.232602ba.akpm@linux-foundation.org>
 <4B858BFC.8020801@redhat.com>
 <20100224125253.2edb4571.akpm@linux-foundation.org>
 <4B8592BB.1040007@redhat.com>
 <20100224131220.396216af.akpm@linux-foundation.org>
 <4B859900.6060504@redhat.com>
 <20100224132818.fb53d10d.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100224132818.fb53d10d.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>
List-ID: <linux-mm.kvack.org>

On Wed, Feb 24, 2010 at 01:28:18PM -0800, Andrew Morton wrote:
> Sounds right.  How much CPU consumption are we seeing from khugepaged?

zero cpu consumption, least on my laptop with default values. Maybe
default isn't aggressive enough but it will still cover very
long-lived allocations just fine. (for short lived allocations using
hugepages or not won't make a difference except during the first page
fault that will run some 50% faster, and cows that will be slower if
there's cache trashing)

> The above-quoted text would make a good addition to the (skimpy)
> changelog!

Agreed, I will integrate it... Also I need to check memcg in
khugepaged.

Thanks!
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
