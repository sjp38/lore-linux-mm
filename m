Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id A145C6B01E3
	for <linux-mm@kvack.org>; Sun, 11 Apr 2010 07:20:04 -0400 (EDT)
Message-ID: <4BC1B034.4050302@redhat.com>
Date: Sun, 11 Apr 2010 14:19:16 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
References: <20100410190233.GA30882@elte.hu> <4BC0CFF4.5000207@redhat.com> <20100410194751.GA23751@elte.hu> <4BC0DE84.3090305@redhat.com> <4BC0E2C4.8090101@redhat.com> <q2s28f2fcbc1004101349ye3e44c9cl4f0c3605c8b3ffd3@mail.gmail.com> <4BC0E556.30304@redhat.com> <4BC19663.8080001@redhat.com> <v2q28f2fcbc1004110237w875d3ec5z8f545c40bcbdf92a@mail.gmail.com> <4BC19916.20100@redhat.com> <20100411110015.GA10149@elte.hu>
In-Reply-To: <20100411110015.GA10149@elte.hu>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Jason Garrett-Glaser <darkshikari@gmail.com>, Mike Galbraith <efault@gmx.de>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On 04/11/2010 02:00 PM, Ingo Molnar wrote:
>>>
>>> Did you make sure to check your stddev on those?
>>>        
>> I'm doing another run to look at variability.
>>      
> Sigh. Could you please stop using stone-age tools like /usr/bin/time and
> instead use:
>    

I did one more run for each setting and got the same results (within a 
second).

> Yes, i know we had a big flamewar about perf kvm, but IMHO that is no reason
> for you to pretend that this tool doesnt exist ;-)
>    

I use it almost daily, not sure why you think I pretend it doesn't exist.

>> Is this something realistic or just a benchmark thing?
>>      
> I'd suggest for you to use the default settings, to make it realistic. (Maybe
> also 'advanced/high-quality' settings that an advanced user would utilize.)
>    

In fact I'm guessing --ultrafast would reduce the gain.  The lower the 
quality, the less time you spend looking at other frames to find 
commonality.  Like bzip2 -1/-9 memory footprint.

> It is no doubt that benchmark advantages can be shown - the point of this
> exercise is to show that there are real-life speedups to various categories of
> non-server apps that hugetlb gives us.
>    

I think hugetlb will mostly help server apps.  Desktop apps simply don't 
have working sets big enough to matter.  There will be exceptions, but 
as a rule, desktop apps won't benefit much from this.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
