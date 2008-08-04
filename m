Message-ID: <4897032E.5020601@linux-foundation.org>
Date: Mon, 04 Aug 2008 08:25:02 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: [RFC:Patch: 000/008](memory hotplug) rough idea of pgdat removing
References: <20080801180522.EC97.E1E9C6FF@jp.fujitsu.com> <489314FE.7080900@linux-foundation.org> <20080802090335.D6C8.E1E9C6FF@jp.fujitsu.com>
In-Reply-To: <20080802090335.D6C8.E1E9C6FF@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Badari Pulavarty <pbadari@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm <linux-mm@kvack.org>, Linux Kernel ML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Yasunori Goto wrote:

>>> Thanks for your comment.
>> Duh. Then the use of RCU would also mean that all of reclaim must
>>  be in a rcu period. So  reclaim cannot sleep anymore.
> 
> I use srcu_read_lock() (sleepable rcu lock) if kernel must be sleep for
> page reclaim. So, my patch basic idea is followings.

But that introduces more overhead in __alloc_pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
