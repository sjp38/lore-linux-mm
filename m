Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 630656B01E3
	for <linux-mm@kvack.org>; Sun, 11 Apr 2010 06:22:46 -0400 (EDT)
Received: by pwi2 with SMTP id 2so3796289pwi.14
        for <linux-mm@kvack.org>; Sun, 11 Apr 2010 03:22:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4BC19916.20100@redhat.com>
References: <alpine.LFD.2.00.1004051347480.21411@i5.linux-foundation.org>
	<4BC0CFF4.5000207@redhat.com> <20100410194751.GA23751@elte.hu>
	<4BC0DE84.3090305@redhat.com> <4BC0E2C4.8090101@redhat.com>
	<q2s28f2fcbc1004101349ye3e44c9cl4f0c3605c8b3ffd3@mail.gmail.com>
	<4BC0E556.30304@redhat.com> <4BC19663.8080001@redhat.com>
	<v2q28f2fcbc1004110237w875d3ec5z8f545c40bcbdf92a@mail.gmail.com>
	<4BC19916.20100@redhat.com>
From: Jason Garrett-Glaser <darkshikari@gmail.com>
Date: Sun, 11 Apr 2010 03:22:24 -0700
Message-ID: <w2k28f2fcbc1004110322m6b9e6252nbfc87666baf6601e@mail.gmail.com>
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Ingo Molnar <mingo@elte.hu>, Mike Galbraith <efault@gmx.de>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Sun, Apr 11, 2010 at 2:40 AM, Avi Kivity <avi@redhat.com> wrote:
> On 04/11/2010 12:37 PM, Jason Garrett-Glaser wrote:
>>
>>> # time x264 --crf 20 --quiet crowd_run_2160p.y4m -o /dev/null --threads=
 2
>>> yuv4mpeg: 3840x2160@50/1fps, 1:1
>>>
>>> encoded 500 frames, 0.68 fps, 251812.80 kb/s
>>>
>>> real =A0 =A012m17.154s
>>> user =A0 =A020m39.151s
>>> sys =A0 =A00m11.727s
>>>
>>> # echo never> =A0/sys/kernel/mm/transparent_hugepage/enabled
>>> # echo never> =A0/sys/kernel/mm/transparent_hugepage/khugepaged/enabled
>>> # time x264 --crf 20 --quiet crowd_run_2160p.y4m -o /dev/null --threads=
 2
>>> yuv4mpeg: 3840x2160@50/1fps, 1:1
>>>
>>> encoded 500 frames, 0.66 fps, 251812.80 kb/s
>>>
>>> real =A0 =A012m37.962s
>>> user =A0 =A021m13.506s
>>> sys =A0 =A00m11.696s
>>>
>>> Just 2.7%, even though the working set was much larger.
>>>
>>
>> Did you make sure to check your stddev on those?
>>
>
> I'm doing another run to look at variability.
>
>> I'm also curious how it compares for --preset ultrafast and so forth.
>>
>
> Is this something realistic or just a benchmark thing?

Well, at 2160p, we're already a bit beyond the bounds of ordinary
applications.  Ultrafast is generally an "unrealistically fast"
setting, getting stupid performance levels like 200fps 1080p encoding
(at the cost of incredibly bad compression).  "veryfast" is probably a
more realistic test case (I know many companies using similar levels
of performance).

Jason

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
