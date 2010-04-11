Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 5B7326B01E3
	for <linux-mm@kvack.org>; Sun, 11 Apr 2010 05:37:49 -0400 (EDT)
Received: by pwi2 with SMTP id 2so3788176pwi.14
        for <linux-mm@kvack.org>; Sun, 11 Apr 2010 02:37:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4BC19663.8080001@redhat.com>
References: <alpine.LFD.2.00.1004051347480.21411@i5.linux-foundation.org>
	<20100410184750.GJ5708@random.random> <20100410190233.GA30882@elte.hu>
	<4BC0CFF4.5000207@redhat.com> <20100410194751.GA23751@elte.hu>
	<4BC0DE84.3090305@redhat.com> <4BC0E2C4.8090101@redhat.com>
	<q2s28f2fcbc1004101349ye3e44c9cl4f0c3605c8b3ffd3@mail.gmail.com>
	<4BC0E556.30304@redhat.com> <4BC19663.8080001@redhat.com>
From: Jason Garrett-Glaser <darkshikari@gmail.com>
Date: Sun, 11 Apr 2010 02:37:27 -0700
Message-ID: <v2q28f2fcbc1004110237w875d3ec5z8f545c40bcbdf92a@mail.gmail.com>
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Ingo Molnar <mingo@elte.hu>, Mike Galbraith <efault@gmx.de>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Sun, Apr 11, 2010 at 2:29 AM, Avi Kivity <avi@redhat.com> wrote:
> On 04/10/2010 11:53 PM, Avi Kivity wrote:
>>
>> On 04/10/2010 11:49 PM, Jason Garrett-Glaser wrote:
>>>
>>>> 3-5% improvement. =A0I had to tune khugepaged to scan more aggressivel=
y
>>>> since
>>>> the run is so short. =A0The working set is only ~100MB here though.
>>>
>>> I'd try some longer runs with larger datasets to do more testing.
>>>
>>> Some things to try:
>>>
>>> 1) Pick a 1080p or even 2160p sequence from
>>> http://media.xiph.org/video/derf/
>>>
>>
>> Ok, I'm downloading crown_run 2160p, but it will take a while.
>>
>
> # time x264 --crf 20 --quiet crowd_run_2160p.y4m -o /dev/null --threads 2
> yuv4mpeg: 3840x2160@50/1fps, 1:1
>
> encoded 500 frames, 0.68 fps, 251812.80 kb/s
>
> real =A0 =A012m17.154s
> user =A0 =A020m39.151s
> sys =A0 =A00m11.727s
>
> # echo never > /sys/kernel/mm/transparent_hugepage/enabled
> # echo never > /sys/kernel/mm/transparent_hugepage/khugepaged/enabled
> # time x264 --crf 20 --quiet crowd_run_2160p.y4m -o /dev/null --threads 2
> yuv4mpeg: 3840x2160@50/1fps, 1:1
>
> encoded 500 frames, 0.66 fps, 251812.80 kb/s
>
> real =A0 =A012m37.962s
> user =A0 =A021m13.506s
> sys =A0 =A00m11.696s
>
> Just 2.7%, even though the working set was much larger.

Did you make sure to check your stddev on those?

I'm also curious how it compares for --preset ultrafast and so forth.

Jason

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
