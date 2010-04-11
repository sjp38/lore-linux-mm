Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id A77606B01EF
	for <linux-mm@kvack.org>; Sun, 11 Apr 2010 05:41:43 -0400 (EDT)
Message-ID: <4BC19916.20100@redhat.com>
Date: Sun, 11 Apr 2010 12:40:38 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
References: <alpine.LFD.2.00.1004051347480.21411@i5.linux-foundation.org> 	<20100410184750.GJ5708@random.random> <20100410190233.GA30882@elte.hu> 	<4BC0CFF4.5000207@redhat.com> <20100410194751.GA23751@elte.hu> 	<4BC0DE84.3090305@redhat.com> <4BC0E2C4.8090101@redhat.com> 	<q2s28f2fcbc1004101349ye3e44c9cl4f0c3605c8b3ffd3@mail.gmail.com> 	<4BC0E556.30304@redhat.com> <4BC19663.8080001@redhat.com> <v2q28f2fcbc1004110237w875d3ec5z8f545c40bcbdf92a@mail.gmail.com>
In-Reply-To: <v2q28f2fcbc1004110237w875d3ec5z8f545c40bcbdf92a@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Jason Garrett-Glaser <darkshikari@gmail.com>
Cc: Ingo Molnar <mingo@elte.hu>, Mike Galbraith <efault@gmx.de>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On 04/11/2010 12:37 PM, Jason Garrett-Glaser wrote:
>
>> # time x264 --crf 20 --quiet crowd_run_2160p.y4m -o /dev/null --threads 2
>> yuv4mpeg: 3840x2160@50/1fps, 1:1
>>
>> encoded 500 frames, 0.68 fps, 251812.80 kb/s
>>
>> real    12m17.154s
>> user    20m39.151s
>> sys    0m11.727s
>>
>> # echo never>  /sys/kernel/mm/transparent_hugepage/enabled
>> # echo never>  /sys/kernel/mm/transparent_hugepage/khugepaged/enabled
>> # time x264 --crf 20 --quiet crowd_run_2160p.y4m -o /dev/null --threads 2
>> yuv4mpeg: 3840x2160@50/1fps, 1:1
>>
>> encoded 500 frames, 0.66 fps, 251812.80 kb/s
>>
>> real    12m37.962s
>> user    21m13.506s
>> sys    0m11.696s
>>
>> Just 2.7%, even though the working set was much larger.
>>      
> Did you make sure to check your stddev on those?
>    

I'm doing another run to look at variability.

> I'm also curious how it compares for --preset ultrafast and so forth.
>    

Is this something realistic or just a benchmark thing?

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
