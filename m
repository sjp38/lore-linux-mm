Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 969836B0078
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 17:34:20 -0400 (EDT)
From: ebiederm@xmission.com (Eric W. Biederman)
References: <20100914234714.8AF506EA@kernel.beaverton.ibm.com>
	<20100915133303.0b232671.kamezawa.hiroyu@jp.fujitsu.com>
	<20100915135016.C9F1.A69D9226@jp.fujitsu.com>
	<1284531262.27089.15725.camel@nimitz>
	<m1d3se7t0h.fsf@fess.ebiederm.org>
	<1284578821.27089.17409.camel@nimitz>
Date: Wed, 15 Sep 2010 14:34:12 -0700
In-Reply-To: <1284578821.27089.17409.camel@nimitz> (Dave Hansen's message of
	"Wed, 15 Sep 2010 12:27:01 -0700")
Message-ID: <m17him4ror.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Subject: Re: [RFC][PATCH] update /proc/sys/vm/drop_caches documentation
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, lnxninja@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

Dave Hansen <dave@linux.vnet.ibm.com> writes:

> On Wed, 2010-09-15 at 11:37 -0700, Eric W. Biederman wrote:
>> > I'm worried that there are users out there experiencing real problems
>> > that aren't reporting it because "workarounds" like this just paper over
>> > the issue.
>> 
>> For what it is worth.  I had a friend ask me about a system that had 50%
>> of it's memory consumed by slab caches.  20GB out of 40GB.  The kernel
>> was suse? 2.6.27 so it's old, but if you are curious.
>> /proc/sys/vm/drop_caches does nothing in that case. 
>
> Was it the reclaimable caches doing it, though?  The other really common
> cause is kmalloc() leaks.

It was reclaimable caches.  He kept seeing the cache sizes of the
problem caches shrink.  On an idle system he said he was seeing
about 16MB/min getting free or something like that.  Something
that would take hours and hours before things freed up.

I asked and my friend told me that according to slabtop the slab
with the most memory used kept changing dramatically and he could
not see a pattern.

So at least on one old kernel on one strange workload there was a problem.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
