Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3BD736B0005
	for <linux-mm@kvack.org>; Thu, 26 Apr 2018 14:49:22 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id j186so19513000qkd.14
        for <linux-mm@kvack.org>; Thu, 26 Apr 2018 11:49:22 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id q13si1220913qvd.273.2018.04.26.11.49.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Apr 2018 11:49:21 -0700 (PDT)
Date: Thu, 26 Apr 2018 21:49:19 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [dm-devel] [PATCH v5] fault-injection: introduce kvmalloc
 fallback options
Message-ID: <20180426214011-mutt-send-email-mst@kernel.org>
References: <1524694663.4100.21.camel@HansenPartnership.com>
 <alpine.LRH.2.02.1804251830540.25124@file01.intranet.prod.int.rdu2.redhat.com>
 <20180426125817.GO17484@dhcp22.suse.cz>
 <alpine.LRH.2.02.1804261006120.32722@file01.intranet.prod.int.rdu2.redhat.com>
 <1524753932.3226.5.camel@HansenPartnership.com>
 <alpine.LRH.2.02.1804261100170.12157@file01.intranet.prod.int.rdu2.redhat.com>
 <1524756256.3226.7.camel@HansenPartnership.com>
 <alpine.LRH.2.02.1804261142480.21152@file01.intranet.prod.int.rdu2.redhat.com>
 <20180426184845-mutt-send-email-mst@kernel.org>
 <alpine.LRH.2.02.1804261202350.24656@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.02.1804261202350.24656@file01.intranet.prod.int.rdu2.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: James Bottomley <James.Bottomley@HansenPartnership.com>, Michal Hocko <mhocko@kernel.org>, David Rientjes <rientjes@google.com>, dm-devel@redhat.com, eric.dumazet@gmail.com, netdev@vger.kernel.org, jasowang@redhat.com, Randy Dunlap <rdunlap@infradead.org>, linux-kernel@vger.kernel.org, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, edumazet@google.com, Andrew Morton <akpm@linux-foundation.org>, virtualization@lists.linux-foundation.org, David Miller <davem@davemloft.net>, Vlastimil Babka <vbabka@suse.cz>

On Thu, Apr 26, 2018 at 12:07:25PM -0400, Mikulas Patocka wrote:
> > IIUC debug kernels mainly exist so people who experience e.g. memory
> > corruption can try and debug the failure. In this case, CONFIG_DEBUG_SG
> > will *already* catch a failure early. Nothing special needs to be done.
> 
> The patch helps people debug such memory coprruptions (such as using DMA 
> API on the result of kvmalloc).

That's my point.  I don't think your patch helps debug any memory
corruptions.  With CONFIG_DEBUG_SG using DMA API already causes a
BUG_ON, that's before any memory can get corrupted.

-- 
MST
