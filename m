Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 659996B0009
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 11:11:09 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id l19so1286670qkk.11
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 08:11:09 -0700 (PDT)
Received: from resqmta-ch2-07v.sys.comcast.net (resqmta-ch2-07v.sys.comcast.net. [2001:558:fe21:29:69:252:207:39])
        by mx.google.com with ESMTPS id y9-v6si1907003qtk.67.2018.04.18.08.11.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Apr 2018 08:11:08 -0700 (PDT)
Date: Wed, 18 Apr 2018 10:11:06 -0500 (CDT)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH] SLUB: Do not fallback to mininum order if __GFP_NORETRY
 is set
In-Reply-To: <alpine.LRH.2.02.1804181102490.13213@file01.intranet.prod.int.rdu2.redhat.com>
Message-ID: <alpine.DEB.2.20.1804181010320.1530@nuc-kabylake>
References: <alpine.DEB.2.20.1804180944180.1062@nuc-kabylake> <alpine.LRH.2.02.1804181102490.13213@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Mike Snitzer <snitzer@redhat.com>, Matthew Wilcox <willy@infradead.org>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, dm-devel@redhat.com, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On Wed, 18 Apr 2018, Mikulas Patocka wrote:

> No, this would hit NULL pointer dereference if page is NULL and
> __GFP_NORETRY is set. You want this:

You are right

Acked-by: Christoph Lameter <cl@linux.com>
