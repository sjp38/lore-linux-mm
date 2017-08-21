Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6A8FD6B04F0
	for <linux-mm@kvack.org>; Mon, 21 Aug 2017 17:40:50 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id q53so30919539qtq.15
        for <linux-mm@kvack.org>; Mon, 21 Aug 2017 14:40:50 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f62si11737882qtd.470.2017.08.21.14.40.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Aug 2017 14:40:49 -0700 (PDT)
Message-ID: <1503351645.6577.76.camel@redhat.com>
Subject: Re: [RFC PATCH 0/6] proactive kcompactd
From: Rik van Riel <riel@redhat.com>
Date: Mon, 21 Aug 2017 17:40:45 -0400
In-Reply-To: <20170821141014.GC1371@cmpxchg.org>
References: <20170727160701.9245-1-vbabka@suse.cz>
	 <alpine.DEB.2.10.1708091353500.1218@chino.kir.corp.google.com>
	 <20170821141014.GC1371@cmpxchg.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>

On Mon, 2017-08-21 at 10:10 -0400, Johannes Weiner wrote:
> 
> I've been toying around with the below patch. It adds a free page
> bitmap, allowing the free scanner to quickly skip over the vast areas
> of used memory. I don't have good data on skip-efficiency at higher
> uptimes and the resulting fragmentation yet. The overhead added to
> the
> page allocator is concerning, but I cannot think of a better way to
> make the search more efficient. What do you guys think?

Michael Tsirkin and I have been thinking about using a bitmap
to allow KVM guests to tell the host which pages are free (and
could be discarded by the host).

Having multiple users for the bitmap makes having one much more
compelling...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
