Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 693386B004D
	for <linux-mm@kvack.org>; Fri,  8 May 2009 10:34:59 -0400 (EDT)
Message-ID: <4A04430F.1090006@redhat.com>
Date: Fri, 08 May 2009 10:34:55 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm] vmscan: make mapped executable pages the first class
 citizen
References: <20090430215034.4748e615@riellaptop.surriel.com> <20090430195439.e02edc26.akpm@linux-foundation.org> <49FB01C1.6050204@redhat.com> <20090501123541.7983a8ae.akpm@linux-foundation.org> <20090503031539.GC5702@localhost> <1241432635.7620.4732.camel@twins> <20090507121101.GB20934@localhost> <20090507151039.GA2413@cmpxchg.org> <20090508030209.GA8892@localhost> <20090508163042.ba4ef116.minchan.kim@barrios-desktop> <20090508080921.GA25411@localhost> <20090508183427.f313770f.minchan.kim@barrios-desktop> <alpine.DEB.1.10.0905081022490.23875@qirst.com>
In-Reply-To: <alpine.DEB.1.10.0905081022490.23875@qirst.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Elladan <elladan@eskimo.com>, Nick Piggin <npiggin@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Fri, 8 May 2009, Minchan Kim wrote:
> 
>>>> Why did you said that "The page_referenced() path will only cover the ""_text_"" section" ?
>>>> Could you elaborate please ?
>>> I was under the wild assumption that only the _text_ section will be
>>> PROT_EXEC mapped.  No?
>> Yes. I support your idea.
> 
> Why do PROT_EXEC mapped segments deserve special treatment? What about the
> other memory segments of the process? Essentials like stack, heap and
> data segments of the libraries?

Christopher, please look at what changed in the VM
since 2.6.29 and you will understand how the stack,
heap and data segments already get special treatment.

Please stop pretending you're an idiot.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
