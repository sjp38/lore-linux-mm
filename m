Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3799E6B0006
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 13:04:42 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id r69so11396070ioe.20
        for <linux-mm@kvack.org>; Tue, 10 Apr 2018 10:04:42 -0700 (PDT)
Received: from resqmta-ch2-10v.sys.comcast.net (resqmta-ch2-10v.sys.comcast.net. [2001:558:fe21:29:69:252:207:42])
        by mx.google.com with ESMTPS id u200-v6si1619182itb.164.2018.04.10.10.04.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Apr 2018 10:04:40 -0700 (PDT)
Date: Tue, 10 Apr 2018 12:04:38 -0500 (CDT)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH 1/2] slab: __GFP_ZERO is incompatible with a
 constructor
In-Reply-To: <20180410155442.GA3614@bombadil.infradead.org>
Message-ID: <alpine.DEB.2.20.1804101203320.29042@nuc-kabylake>
References: <20180410125351.15837-1-willy@infradead.org> <alpine.DEB.2.20.1804100920110.27333@nuc-kabylake> <20180410155442.GA3614@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, stable@vger.kernel.org

On Tue, 10 Apr 2018, Matthew Wilcox wrote:

> Are you willing to have this kind of bug go uncaught for a while?

There will be frequent allocations and this will show up at some point.

Also you could put this into the debug only portions somehwere so we
always catch it when debugging is on,
'
