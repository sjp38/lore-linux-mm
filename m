Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 77D096B0038
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 11:56:24 -0400 (EDT)
Received: by widdq5 with SMTP id dq5so54690824wid.1
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 08:56:23 -0700 (PDT)
Received: from mailrelay.lanline.com (mailrelay.lanline.com. [216.187.10.16])
        by mx.google.com with ESMTPS id lo6si22241893wic.41.2015.08.24.08.56.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 24 Aug 2015 08:56:23 -0700 (PDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <21979.15999.82965.295320@quad.stoffel.home>
Date: Mon, 24 Aug 2015 11:55:43 -0400
From: "John Stoffel" <john@stoffel.org>
Subject: Re: [PATCH 3/3 v4] mm/vmalloc: Cache the vmalloc memory info
In-Reply-To: <20150824151114.18743.qmail@ns.horizon.com>
References: <21979.6150.929309.800457@quad.stoffel.home>
	<20150824151114.18743.qmail@ns.horizon.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: George Spelvin <linux@horizon.com>
Cc: john@stoffel.org, mingo@kernel.org, dave@sr71.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux@rasmusvillemoes.dk, peterz@infradead.org, riel@redhat.com, rientjes@google.com, torvalds@linux-foundation.org


George> John Stoffel <john@stoffel.org> wrote:
>>> vmap_info_gen should be initialized to 1 to force an initial
>>> cache update.

>> Blech, it should be initialized with a proper #define
>> VMAP_CACHE_NEEDS_UPDATE 1, instead of more magic numbers.

George> Er... this is a joke, right?

Not really.  The comment made before was that by setting this variable
to zero, it wasn't properly initialized.  Which implies that either
the API is wrong... or we should be documenting it better.   I just
went in the direction of the #define instead of a comment. 

George> First, this number is used exactly once, and it's not part of
George> a collection of similar numbers.  And the definition would be
George> adjacent to the use.

George> We have easier ways of accomplishing that, called "comments".

Sure, that would be the better solution in this case.  

George> Second, your proposed name is misleading.  "needs update" is defined
George> as vmap_info_gen != vmap_info_cache_gen.  There is no particular value
George> of either that has this meaning.

George> For example, initializing vmap_info_cache_gen to -1 would do just as well.
George> (I actually considered that before deciding that +1 was "simpler" than -1.)

See, I just threw out a dumb suggestion without reading the patch
properly.  My fault.

George> (John, my apologies if I went over the top and am contributing to LKML's
George> reputation for flaming.  I *did* actually laugh, and *do* think it's a
George> dumb idea, but my annoyance is really directed at unpleasant memories of
George> mindless application of coding style guidelines.  In this case, I suspect
George> you just posted before reading carefully enough to see the subtle logic.)

Nope, I'm in the wrong here.  And your comment here is wonderful, I
really do appreciate how you handled my ham fisted attempt to
contribute.  But I've got thick skin and I'll keep trying in my free
time to comment on patches when I can.

John

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
