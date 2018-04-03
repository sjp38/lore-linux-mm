Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 38D0B6B0006
	for <linux-mm@kvack.org>; Tue,  3 Apr 2018 07:41:21 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id x8-v6so9505557pln.9
        for <linux-mm@kvack.org>; Tue, 03 Apr 2018 04:41:21 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [198.137.202.133])
        by mx.google.com with ESMTPS id h91-v6si356483pld.716.2018.04.03.04.41.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 03 Apr 2018 04:41:20 -0700 (PDT)
Date: Tue, 3 Apr 2018 04:41:17 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 3/4] mm: Add free()
Message-ID: <20180403114117.GA5832@bombadil.infradead.org>
References: <20180322195819.24271-1-willy@infradead.org>
 <20180322195819.24271-4-willy@infradead.org>
 <1e95ce64-828b-1214-a930-1ffaedfa00b8@rasmusvillemoes.dk>
 <20180323143435.GB5624@bombadil.infradead.org>
 <20180403085059.GB3926@amd>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180403085059.GB3926@amd>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: Rasmus Villemoes <linux@rasmusvillemoes.dk>, linux-mm@kvack.org, Kirill Tkhai <ktkhai@virtuozzo.com>, Matthew Wilcox <mawilcox@microsoft.com>, linux-kernel@vger.kernel.org, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Tue, Apr 03, 2018 at 10:50:59AM +0200, Pavel Machek wrote:
> > gcc already does some nice optimisations around free().  For example, it
> > can eliminate dead stores:
> 
> Are we comfortable with that optimalization for kernel?
> 
> us: "Hey, let's remove those encryption keys before freeing memory."
> gcc: :-).
> 
> us: "Hey, we want to erase lock magic values not to cause confusion
> later."
> gcc: "I like confusion!"
> 
> Yes, these probably can be fixed by strategic "volatile" and/or
> barriers, but...

Exactly, we should mark those sites explicitly with volatile so that 
they aren't dead stores.
