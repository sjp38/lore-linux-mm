Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id A986D6B004D
	for <linux-mm@kvack.org>; Thu, 22 Mar 2012 10:23:57 -0400 (EDT)
Message-ID: <4F6B3591.10003@parallels.com>
Date: Thu, 22 Mar 2012 18:22:09 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: object allocation benchmark
References: <4F6743C2.3090906@parallels.com> <alpine.DEB.2.00.1203191028160.19189@router.home>
In-Reply-To: <alpine.DEB.2.00.1203191028160.19189@router.home>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Pekka Enberg <penberg@kernel.org>, Suleiman Souhlal <suleiman@google.com>, KAMEZAWA
 Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On 03/19/2012 07:28 PM, Christoph Lameter wrote:
> On Mon, 19 Mar 2012, Glauber Costa wrote:
>
>> I was wondering: Which benchmark would be considered the canonical one to
>> demonstrate the speed of the slub/slab after changes? In particular, I have
>> the kmem-memcg in mind
>
> I have some in kernel benchmarking tools for page allocator and slab
> allocators. But they are not really clean patches.
>
>
I'd given it a try.

So in general, Suleiman patches perform fine against bare slab, the 
differences being in the order of ~ 1%. There are some spikes a little 
bit above that, that would deserve more analysis.

However, reason I decided to report early, is this test:
"1 alloc N free test". It is quite erratic. memcg+kmem sometimes 
performs 15 % worse, sometimes 30 % better... Always right after a cold 
boot.

I was wondering if you usually see such behavior for this test, and has 
some tips on the setup in case I'm doing anything wrong ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
