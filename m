Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7F66C830F1
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 10:49:12 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id u191so485599339oie.3
        for <linux-mm@kvack.org>; Mon, 29 Aug 2016 07:49:12 -0700 (PDT)
Received: from resqmta-po-02v.sys.comcast.net (resqmta-po-02v.sys.comcast.net. [2001:558:fe16:19:96:114:154:161])
        by mx.google.com with ESMTPS id m195si14322805itm.123.2016.08.29.07.49.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Aug 2016 07:49:11 -0700 (PDT)
Date: Mon, 29 Aug 2016 09:49:09 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: what is the purpose of SLAB and SLUB
In-Reply-To: <20160829134458.GD2968@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.20.1608290947140.21668@east.gentwo.org>
References: <1471458050-29622-1-git-send-email-aruna.ramakrishna@oracle.com> <20160818115218.GJ30162@dhcp22.suse.cz> <20160823021303.GB17039@js1304-P5Q-DELUXE> <20160823153807.GN23577@dhcp22.suse.cz> <20160824082057.GT2693@suse.de>
 <alpine.DEB.2.20.1608242240460.1837@east.gentwo.org> <20160825100707.GU2693@suse.de> <alpine.DEB.2.20.1608251451070.10766@east.gentwo.org> <87h9a71clo.fsf@tassilo.jf.intel.com> <20160829134458.GD2968@dhcp22.suse.cz>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andi Kleen <andi@firstfloor.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Aruna Ramakrishna <aruna.ramakrishna@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Kravetz <mike.kravetz@oracle.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Jiri Slaby <jslaby@suse.cz>

On Mon, 29 Aug 2016, Michal Hocko wrote:

> Compaction can certainly help and the more we are proactive in that
> direction the better. Vlastimil has already done a first step in that
> direction and we a have a dedicated kcompactd kernel thread for that
> purpose. But I guess what Mel had in mind is the latency of higher
> order pages which is inherently higher with the current page allocator
> no matter how well the compaction works. There are other changes, mostly
> for the fast path, needed to make higher order pages less of a second
> citizen.

Compaction needs to be able to move many more types of kernel objects out
of the way. I think if the callbacks that were merged for the migration of
CMA pages are made usable for slab allocations then we may make some
progress there. This would require the creator of a slab cache to specify
functions that allow the migration of an object. Would require additional
subsystem specific code. But doing that for inodes and dentries could be
very benficial for compaction.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
