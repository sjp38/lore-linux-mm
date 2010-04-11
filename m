Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id C16EF6B01E3
	for <linux-mm@kvack.org>; Sun, 11 Apr 2010 05:30:22 -0400 (EDT)
Message-ID: <4BC19663.8080001@redhat.com>
Date: Sun, 11 Apr 2010 12:29:07 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
References: <alpine.LFD.2.00.1004051347480.21411@i5.linux-foundation.org> 	<alpine.LFD.2.00.1004051836000.5870@i5.linux-foundation.org> 	<alpine.LFD.2.00.1004051917310.3487@i5.linux-foundation.org> 	<20100406090813.GA14098@elte.hu> <20100410184750.GJ5708@random.random> 	<20100410190233.GA30882@elte.hu> <4BC0CFF4.5000207@redhat.com> 	<20100410194751.GA23751@elte.hu> <4BC0DE84.3090305@redhat.com> 	<4BC0E2C4.8090101@redhat.com> <q2s28f2fcbc1004101349ye3e44c9cl4f0c3605c8b3ffd3@mail.gmail.com> <4BC0E556.30304@redhat.com>
In-Reply-To: <4BC0E556.30304@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Jason Garrett-Glaser <darkshikari@gmail.com>
Cc: Ingo Molnar <mingo@elte.hu>, Mike Galbraith <efault@gmx.de>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On 04/10/2010 11:53 PM, Avi Kivity wrote:
> On 04/10/2010 11:49 PM, Jason Garrett-Glaser wrote:
>>
>>> 3-5% improvement.  I had to tune khugepaged to scan more 
>>> aggressively since
>>> the run is so short.  The working set is only ~100MB here though.
>> I'd try some longer runs with larger datasets to do more testing.
>>
>> Some things to try:
>>
>> 1) Pick a 1080p or even 2160p sequence from 
>> http://media.xiph.org/video/derf/
>>
>
> Ok, I'm downloading crown_run 2160p, but it will take a while.
>

# time x264 --crf 20 --quiet crowd_run_2160p.y4m -o /dev/null --threads 2
yuv4mpeg: 3840x2160@50/1fps, 1:1

encoded 500 frames, 0.68 fps, 251812.80 kb/s

real    12m17.154s
user    20m39.151s
sys    0m11.727s

# echo never > /sys/kernel/mm/transparent_hugepage/enabled
# echo never > /sys/kernel/mm/transparent_hugepage/khugepaged/enabled
# time x264 --crf 20 --quiet crowd_run_2160p.y4m -o /dev/null --threads 2
yuv4mpeg: 3840x2160@50/1fps, 1:1

encoded 500 frames, 0.66 fps, 251812.80 kb/s

real    12m37.962s
user    21m13.506s
sys    0m11.696s

Just 2.7%, even though the working set was much larger.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
