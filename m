Date: Wed, 19 Mar 2008 16:33:50 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [0/2] vmalloc: Add /proc/vmallocinfo to display mappings
In-Reply-To: <20080319150704.d3f090e6.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0803191628480.4070@schroedinger.engr.sgi.com>
References: <20080318222701.788442216@sgi.com> <20080319111943.0E1B.KOSAKI.MOTOHIRO@jp.fujitsu.com>
 <20080319150704.d3f090e6.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 19 Mar 2008, Andrew Morton wrote:

> I was just about to ask whether we actually need the feature - I don't
> recall ever having needed it, nor do I recall seeing anyone else need it.
> 
> Why is it useful?

It allows to see the users of vmalloc. That is important if vmalloc space 
is scarce (i386 for example).

And its going to be important for the compound page fallback to vmalloc.
Many of the current users can be switched to use compound pages with
fallback. This means that the number of users of vmalloc is reduced and 
page tables no longer necessary to access the memory.
/proc/vmallocinfo allows to review how that reduction occurs.

If memory becomes fragmented and larger order allocations are no longer 
possible then /proc/vmallocinfo allows to see which compound 
page allocations fell back to virtual compound pages. That is important 
for new users of virtual compound pages. Such as order 1 stack allocation 
etc that may fallback to virtual compound pages in the future.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
