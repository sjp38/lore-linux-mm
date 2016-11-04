Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 566E7280281
	for <linux-mm@kvack.org>; Fri,  4 Nov 2016 11:59:17 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id u15so128281556oie.6
        for <linux-mm@kvack.org>; Fri, 04 Nov 2016 08:59:17 -0700 (PDT)
Received: from mail-oi0-x242.google.com (mail-oi0-x242.google.com. [2607:f8b0:4003:c06::242])
        by mx.google.com with ESMTPS id s194si9111916oih.181.2016.11.04.08.59.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Nov 2016 08:59:16 -0700 (PDT)
Received: by mail-oi0-x242.google.com with SMTP id 62so13338139oif.1
        for <linux-mm@kvack.org>; Fri, 04 Nov 2016 08:59:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20161104182942.47c4d544@roar.ozlabs.ibm.com>
References: <20161102070346.12489-1-npiggin@gmail.com> <20161102070346.12489-3-npiggin@gmail.com>
 <CA+55aFxhxfevU1uKwHmPheoU7co4zxxcri+AiTpKz=1_Nd0_ig@mail.gmail.com>
 <20161103144650.70c46063@roar.ozlabs.ibm.com> <CA+55aFyzf8r2q-HLfADcz74H-My_GY-z15yLrwH-KUqd486Q0A@mail.gmail.com>
 <20161104134049.6c7d394b@roar.ozlabs.ibm.com> <20161104182942.47c4d544@roar.ozlabs.ibm.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 4 Nov 2016 08:59:15 -0700
Message-ID: <CA+55aFxoT82RocOCZ9+k7_NZ+KZNtCQrwzNd=reB0n03xDj4-A@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm: add PageWaiters bit to indicate waitqueue should
 be checked
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Piggin <npiggin@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>

On Fri, Nov 4, 2016 at 12:29 AM, Nicholas Piggin <npiggin@gmail.com> wrote:
> Oh, okay, the zone lookup. Well I am of the impression that most of the
> cache misses are coming from the waitqueue hash table itself.

No.

Nick, stop this idiocy.

NUMBERS, Nick. NUMBERS.

I posted numbers in "page_waitqueue() considered harmful" on linux-mm.

And quite frankly, before _you_ start posting numbers, that zone crap
IS NEVER COMING BACK.

What's so hard about this concept? We don't add crazy complexity
without numbers. Numbers that I bet you will not be able to provide,
because quiet frankly, even in your handwavy "what about lots of
concurrent IO from hundreds of threads" situation, that wait-queue
will NOT BE NOTICEABLE.

So no "impressions". No "what abouts". No "threaded IO" excuses. The
_only_ thing that matters is numbers. If you don't have them, don't
bother talking about that zone patch.

             Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
