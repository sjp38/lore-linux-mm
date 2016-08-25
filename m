Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 14D5182F6B
	for <linux-mm@kvack.org>; Thu, 25 Aug 2016 00:10:06 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id i144so121050899oib.0
        for <linux-mm@kvack.org>; Wed, 24 Aug 2016 21:10:06 -0700 (PDT)
Received: from resqmta-ch2-08v.sys.comcast.net (resqmta-ch2-08v.sys.comcast.net. [2001:558:fe21:29:69:252:207:40])
        by mx.google.com with ESMTPS id b64si15471536itd.6.2016.08.24.21.10.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Aug 2016 21:10:04 -0700 (PDT)
Date: Wed, 24 Aug 2016 23:10:03 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: what is the purpose of SLAB and SLUB
In-Reply-To: <8760qr8orh.fsf@tassilo.jf.intel.com>
Message-ID: <alpine.DEB.2.20.1608242302290.1837@east.gentwo.org>
References: <1471458050-29622-1-git-send-email-aruna.ramakrishna@oracle.com> <20160818115218.GJ30162@dhcp22.suse.cz> <20160823021303.GB17039@js1304-P5Q-DELUXE> <20160823153807.GN23577@dhcp22.suse.cz> <8760qr8orh.fsf@tassilo.jf.intel.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Michal Hocko <mhocko@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Aruna Ramakrishna <aruna.ramakrishna@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Kravetz <mike.kravetz@oracle.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Jiri Slaby <jslaby@suse.cz>

On Tue, 23 Aug 2016, Andi Kleen wrote:

> Why would you stop someone from working on SLAB if they want to?
>
> Forcibly enforcing a freeze on something can make sense if you're
> in charge of a team to conserve resources, but in Linux the situation is
> very different.

I agree and frankly having multiple allocators is something good.
Features that are good in one are copied to the other and enhanced in the
process. I think this has driven code development quite a bit.

Every allocator has a different basic approach to storage layout and
synchronization which determines performance in various usage scenarios.
The competition of seeing if the developer that is a fan of one can come
up with a way to make performance better or storage use more effective in
a situation where another shows better numbers is good.

There may be more creative ways of coming up with new ways of laying out
storage in the future and I would like to have the flexibility in the
kernel to explore those if necessary with additional variations.

The more common code we can isolate the easier it will become to just try
out a new layout and a new form of serialization to see if it provides
advantages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
