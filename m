Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 715E66B01F1
	for <linux-mm@kvack.org>; Sat, 10 Apr 2010 16:49:33 -0400 (EDT)
Received: by pvg11 with SMTP id 11so2627022pvg.14
        for <linux-mm@kvack.org>; Sat, 10 Apr 2010 13:49:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4BC0E2C4.8090101@redhat.com>
References: <alpine.LFD.2.00.1004051347480.21411@i5.linux-foundation.org>
	<alpine.LFD.2.00.1004051836000.5870@i5.linux-foundation.org>
	<alpine.LFD.2.00.1004051917310.3487@i5.linux-foundation.org>
	<20100406090813.GA14098@elte.hu> <20100410184750.GJ5708@random.random>
	<20100410190233.GA30882@elte.hu> <4BC0CFF4.5000207@redhat.com>
	<20100410194751.GA23751@elte.hu> <4BC0DE84.3090305@redhat.com>
	<4BC0E2C4.8090101@redhat.com>
From: Jason Garrett-Glaser <darkshikari@gmail.com>
Date: Sat, 10 Apr 2010 13:49:12 -0700
Message-ID: <q2s28f2fcbc1004101349ye3e44c9cl4f0c3605c8b3ffd3@mail.gmail.com>
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Ingo Molnar <mingo@elte.hu>, Mike Galbraith <efault@gmx.de>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Sat, Apr 10, 2010 at 1:42 PM, Avi Kivity <avi@redhat.com> wrote:
> On 04/10/2010 11:24 PM, Avi Kivity wrote:
>>>
>>> Oh, this tickled some memories: x264 compressed encoding can be very
>>> cache and
>>> TLB intense. Something like the encoding of a 350 MB video file:
>>>
>>> =A0 wget http://media.xiph.org/video/derf/y4m/soccer_4cif.y4m =A0 =A0 =
=A0 # NOTE:
>>> 350 MB!
>>> =A0 x264 --crf 20 --quiet soccer_4cif.y4m -o /dev/null --threads 4
>>>
>>> would be another thing worth trying with transparent-hugetlb enabled.
>>>
>>
>> I'll try it out.
>>
>
> 3-5% improvement. =A0I had to tune khugepaged to scan more aggressively s=
ince
> the run is so short. =A0The working set is only ~100MB here though.

I'd try some longer runs with larger datasets to do more testing.

Some things to try:

1) Pick a 1080p or even 2160p sequence from http://media.xiph.org/video/der=
f/

2) Use --preset ultrafast or similar to do a ridiculously
memory-bandwidth-limited runthrough.

3) Use --preset veryslow or similar to do a very not-memory-limited runthro=
ugh.

Jason

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
