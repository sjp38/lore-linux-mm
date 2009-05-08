Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 83ACD6B0062
	for <linux-mm@kvack.org>; Fri,  8 May 2009 13:40:49 -0400 (EDT)
Received: by gxk20 with SMTP id 20so3394770gxk.14
        for <linux-mm@kvack.org>; Fri, 08 May 2009 10:41:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.1.10.0905081022490.23875@qirst.com>
References: <20090430215034.4748e615@riellaptop.surriel.com>
	 <20090503031539.GC5702@localhost> <1241432635.7620.4732.camel@twins>
	 <20090507121101.GB20934@localhost> <20090507151039.GA2413@cmpxchg.org>
	 <20090508030209.GA8892@localhost>
	 <20090508163042.ba4ef116.minchan.kim@barrios-desktop>
	 <20090508080921.GA25411@localhost>
	 <20090508183427.f313770f.minchan.kim@barrios-desktop>
	 <alpine.DEB.1.10.0905081022490.23875@qirst.com>
Date: Sat, 9 May 2009 02:41:26 +0900
Message-ID: <2f11576a0905081041nb26140bx56394f8e232fb59e@mail.gmail.com>
Subject: Re: [PATCH -mm] vmscan: make mapped executable pages the first class
	citizen
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Elladan <elladan@eskimo.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

>> > > Why did you said that "The page_referenced() path will only cover th=
e ""_text_"" section" ?
>> > > Could you elaborate please ?
>> >
>> > I was under the wild assumption that only the _text_ section will be
>> > PROT_EXEC mapped. =A0No?
>>
>> Yes. I support your idea.
>
> Why do PROT_EXEC mapped segments deserve special treatment? What about th=
e
> other memory segments of the process? Essentials like stack, heap and
> data segments of the libraries?

Currently, file-backed page and swap-backed page are lived in separate lru.

text section: file
stack: anon
heap: anon
data segment: anon

and, streaming IO problem don't affect swap-backed lru. it's only
file-backed lru problem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
