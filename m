Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f200.google.com (mail-yb0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9A1E26B000C
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 11:10:24 -0400 (EDT)
Received: by mail-yb0-f200.google.com with SMTP id t11-v6so10228031ybc.15
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 08:10:24 -0700 (PDT)
Received: from resqmta-ch2-05v.sys.comcast.net (resqmta-ch2-05v.sys.comcast.net. [2001:558:fe21:29:69:252:207:37])
        by mx.google.com with ESMTPS id n128si1928080ywe.219.2018.04.16.08.10.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Apr 2018 08:10:23 -0700 (PDT)
Date: Mon, 16 Apr 2018 10:10:20 -0500 (CDT)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH v3 2/2] slab: __GFP_ZERO is incompatible with a
 constructor
In-Reply-To: <20180412191322.GA21205@bombadil.infradead.org>
Message-ID: <alpine.DEB.2.20.1804161009590.8424@nuc-kabylake>
References: <20180411060320.14458-1-willy@infradead.org> <20180411060320.14458-3-willy@infradead.org> <alpine.DEB.2.20.1804110842560.3788@nuc-kabylake> <20180411192448.GD22494@bombadil.infradead.org> <alpine.DEB.2.20.1804111601090.7458@nuc-kabylake>
 <20180411235652.GA28279@bombadil.infradead.org> <alpine.DEB.2.20.1804120907100.11220@nuc-kabylake> <20180412142718.GA20398@bombadil.infradead.org> <20180412191322.GA21205@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Mel Gorman <mgorman@techsingularity.net>

On Thu, 12 Apr 2018, Matthew Wilcox wrote:

> __GFP_ZERO requests that the object be initialised to all-zeroes,
> while the purpose of a constructor is to initialise an object to a
> particular pattern.  We cannot do both.  Add a warning to catch any
> users who mistakenly pass a __GFP_ZERO flag when allocating a slab with
> a constructor.

Acked-by: Christoph Lameter <cl@linux.com>
