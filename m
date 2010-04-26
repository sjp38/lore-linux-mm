Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id F31526B01E3
	for <linux-mm@kvack.org>; Mon, 26 Apr 2010 00:31:59 -0400 (EDT)
Received: by iwn40 with SMTP id 40so2897372iwn.1
        for <linux-mm@kvack.org>; Sun, 25 Apr 2010 21:31:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100426115347.2ee2a917.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100423120148.9ffa5881.kamezawa.hiroyu@jp.fujitsu.com>
	 <20100423095922.GJ30306@csn.ul.ie> <20100423155801.GA14351@csn.ul.ie>
	 <20100424110200.b491ec5f.kamezawa.hiroyu@jp.fujitsu.com>
	 <20100424104324.GD14351@csn.ul.ie>
	 <20100426084901.15c09a29.kamezawa.hiroyu@jp.fujitsu.com>
	 <20100426115347.2ee2a917.kamezawa.hiroyu@jp.fujitsu.com>
Date: Mon, 26 Apr 2010 13:31:59 +0900
Message-ID: <h2g28c262361004252131i4b38be55y92fffd9747b3166@mail.gmail.com>
Subject: Re: [BUGFIX][mm][PATCH] fix migration race in rmap_walk
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Christoph Lameter <cl@linux.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, Apr 26, 2010 at 11:53 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Mon, 26 Apr 2010 08:49:01 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>
>> On Sat, 24 Apr 2010 11:43:24 +0100
>> Mel Gorman <mel@csn.ul.ie> wrote:
>
>> > It looks nice but it still broke after 28 hours of running. The
>> > seq-counter is still insufficient to catch all changes that are made to
>> > the list. I'm beginning to wonder if a) this really can be fully safely
>> > locked with the anon_vma changes and b) if it has to be a spinlock to
>> > catch the majority of cases but still a lazy cleanup if there happens to
>> > be a race. It's unsatisfactory and I'm expecting I'll either have some
>> > insight to the new anon_vma changes that allow it to be locked or Rik
>> > knows how to restore the original behaviour which as Andrea pointed out
>> > was safe.
>> >
>> Ouch. Hmm, how about the race in fork() I pointed out ?
>>
> Forget this. Sorry for noise.

Yes. It was due to my wrong explanation.
Sorry for that, Kame.


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
