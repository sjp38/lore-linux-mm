Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 094BD6B01E3
	for <linux-mm@kvack.org>; Mon,  5 Apr 2010 16:26:55 -0400 (EDT)
Received: by fg-out-1718.google.com with SMTP id l26so630011fgb.8
        for <linux-mm@kvack.org>; Mon, 05 Apr 2010 13:26:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100405193616.GA5125@elte.hu>
References: <patchbomb.1270168887@v2.random>
	 <20100405120906.0abe8e58.akpm@linux-foundation.org>
	 <20100405193616.GA5125@elte.hu>
Date: Mon, 5 Apr 2010 23:26:52 +0300
Message-ID: <n2j84144f021004051326mab7cd8fbm949115748a3d78b6@mail.gmail.com>
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

Hi Ingo,

On Mon, Apr 5, 2010 at 10:36 PM, Ingo Molnar <mingo@elte.hu> wrote:
>> Problem. =A0It appears that these patches have only been sent to linux-m=
m.
>> Linus doesn't read linux-mm and has never seen them. =A0I do think we sh=
ould
>> get things squared away with him regarding the overall intent and
>> implementation approach before trying to go further.
>>
>> I forwarded "[PATCH 27 of 41] transparent hugepage core" and his summary=
 was
>> "So I don't hate the patch, but it sure as hell doesn't make me happy
>> either. =A0And if the only advantage is about TLB miss costs, I really d=
on't
>> see the point personally.". =A0So if there's more benefit to the patches=
 than
>> this, that will need some expounding upon.
>>
>> So I'd suggest that you a) address some minor Linus comments which I'll
>> forward separately, b) rework [patch 0/n] to provide a complete descript=
ion
>> of the benefits and the downsides (if that isn't there already) and c)
>> resend everything, cc'ing Linus and linux-kernel and we'll get it thrash=
ed
>> out.
>>
>> Sorry. =A0Normally I use my own judgement on MM patches, but in this cas=
e if I
>> was asked "why did you send all this stuff", I don't believe I personall=
y
>> have strong enough arguments to justify the changes - you're in a better
>> position than I to make that case. =A0Plus this is a *large* patchset, a=
nd it
>> plays in an area where Linus is known to have, err, opinions.
>
> Not sure whether it got mentioned but one area where huge pages are rathe=
r
> useful are apps/middleware that does some sort of GC with tons of RAM.

Dunno what your measure of "tons of RAM" is but yeah, IIRC when you go
above 2 GB or so, huge pages are usually a big win.

> There the 512x reduction in remapping and TLB flush costs (not just TLB m=
iss
> costs) obviously makes for a big difference not just in straight
> performance/latency but also in cache footprint. AFAIK most GC concepts t=
oday
> (that cover many gigabytes of memory) are limited by remap and TLB flush
> performance.

Which remap are you referring to?

AFAIK, most modern GCs split memory in young and old generation
"zones" and _copy_ surviving objects from the former to the latter if
their lifetime exceeds some threshold. The JVM keeps scanning the
smaller young generation very aggressively which causes TLB pressure
and scans the larger old generation less often.

                       Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
